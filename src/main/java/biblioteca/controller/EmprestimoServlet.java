package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import biblioteca.model.Emprestimo;
import biblioteca.model.Livro;
import biblioteca.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/emprestimos")
public class EmprestimoServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO = "biblioteca";
    private static final String SENHA = "biblioteca";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = (Usuario) request.getSession().getAttribute("usuarioLogado");
        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String sql = "SELECT e.*, l.titulo, l.autor FROM emprestimo e "
                   + "JOIN livro l ON e.livro_id = l.id "
                   + "WHERE e.usuario_id = ? ORDER BY e.data_emprestimo DESC";
        
        List<Emprestimo> lista = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, usuario.getId());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Emprestimo emp = new Emprestimo();
                    emp.setId(rs.getInt("id"));
                    emp.setDataEmprestimo(rs.getDate("data_emprestimo"));
                    emp.setDataPrevistaDevolucao(rs.getDate("data_prevista_devolucao"));
                    emp.setDataDevolucaoReal(rs.getDate("data_devolucao_real"));
                    emp.setMulta(rs.getDouble("multa"));

                    Livro l = new Livro();
                    l.setId(rs.getInt("livro_id")); 
                    l.setTitulo(rs.getString("titulo"));
                    l.setAutor(rs.getString("autor"));
                    emp.setLivro(l);

                    lista.add(emp);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao listar histórico", e);
        }

        request.setAttribute("meusEmprestimos", lista);
        request.getRequestDispatcher("historico.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = (Usuario) request.getSession().getAttribute("usuarioLogado");
        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String livroIdStr = request.getParameter("livroId");
        if (livroIdStr == null || livroIdStr.isEmpty()) {
            response.sendRedirect("livros?erro=LivroNaoInformado");
            return;
        }
        int livroId = Integer.parseInt(livroIdStr);

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {

            String sqlBloqueio = "SELECT COUNT(*) FROM emprestimo "
                               + "WHERE usuario_id = ? AND ("
                               + "  multa > 0 OR "
                               + "  (data_devolucao_real IS NULL AND data_prevista_devolucao < CURRENT_DATE)"
                               + ")";
            
            boolean bloqueado = false;
            try (PreparedStatement stmtCheck = conn.prepareStatement(sqlBloqueio)) {
                stmtCheck.setInt(1, usuario.getId());
                try (ResultSet rs = stmtCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        bloqueado = true;
                    }
                }
            }

            if (bloqueado) {
                request.setAttribute("erro", "Empréstimo negado: Pendências financeiras ou atrasos.");
                response.sendRedirect("livros?erro=Bloqueado");
                return;
            }

            String sqlDuplicado = "SELECT COUNT(*) FROM emprestimo WHERE usuario_id = ? AND livro_id = ? AND data_devolucao_real IS NULL";
            
            try (PreparedStatement stmtDup = conn.prepareStatement(sqlDuplicado)) {
                stmtDup.setInt(1, usuario.getId());
                stmtDup.setInt(2, livroId);
                try (ResultSet rsDup = stmtDup.executeQuery()) {
                    if (rsDup.next() && rsDup.getInt(1) > 0) {
                        response.sendRedirect("livros?erro=LivroJaComUsuario");
                        return;
                    }
                }
            }

            conn.setAutoCommit(false);
            try {
                boolean disponivel = false;
                try (PreparedStatement stmtCheckLivro = conn.prepareStatement("SELECT quantidade_disponivel FROM livro WHERE id = ?")) {
                    stmtCheckLivro.setInt(1, livroId);
                    try (ResultSet rs = stmtCheckLivro.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            disponivel = true;
                        }
                    }
                }

                if (!disponivel) {
                    throw new SQLException("Livro indisponível.");
                }

                LocalDate hoje = LocalDate.now();
                LocalDate devolucao = hoje.plusDays(7);

                String sqlInsert = "INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao) VALUES (?, ?, ?, ?)";
                
                try (PreparedStatement stmtIns = conn.prepareStatement(sqlInsert)) {
                    stmtIns.setInt(1, usuario.getId());
                    stmtIns.setInt(2, livroId);
                    stmtIns.setDate(3, java.sql.Date.valueOf(hoje));
                    stmtIns.setDate(4, java.sql.Date.valueOf(devolucao));
                    stmtIns.executeUpdate();
                }

                try (PreparedStatement stmtUpd = conn.prepareStatement("UPDATE livro SET quantidade_disponivel = quantidade_disponivel - 1 WHERE id = ?")) {
                    stmtUpd.setInt(1, livroId);
                    stmtUpd.executeUpdate();
                }

                conn.commit();
                response.sendRedirect("emprestimos");
                
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new ServletException("Falha no empréstimo: " + e.getMessage(), e);
        }
    }
}