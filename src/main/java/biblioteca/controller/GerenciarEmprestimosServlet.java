package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import biblioteca.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/gerenciarEmprestimos")
public class GerenciarEmprestimosServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO_DB = "biblioteca";
    private static final String SENHA_DB = "biblioteca";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario u = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        if (u == null || !"admin".equals(u.getTipo())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String filtroNome = request.getParameter("buscaNome");
        String filtroMatricula = request.getParameter("buscaMatricula");
        String filtroLivro = request.getParameter("buscaLivro");
        List<Map<String, Object>> listaResultados = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT e.id as emp_id, e.data_emprestimo, e.data_prevista_devolucao, ");
        sql.append("u.nome, u.matricula, l.titulo, l.id as livro_id ");
        sql.append("FROM emprestimo e ");
        sql.append("JOIN usuario u ON e.usuario_id = u.id ");
        sql.append("JOIN livro l ON e.livro_id = l.id ");
        sql.append("WHERE e.data_devolucao_real IS NULL ");

        List<Object> parametros = new ArrayList<>();
        if (filtroNome != null && !filtroNome.trim().isEmpty()) {
            sql.append("AND LOWER(u.nome) LIKE ? ");
            parametros.add("%" + filtroNome.toLowerCase() + "%");
        }
        if (filtroMatricula != null && !filtroMatricula.trim().isEmpty()) {
            sql.append("AND u.matricula = ? ");
            parametros.add(filtroMatricula);
        }
        if (filtroLivro != null && !filtroLivro.trim().isEmpty()) {
            sql.append("AND LOWER(l.titulo) LIKE ? ");
            parametros.add("%" + filtroLivro.toLowerCase() + "%");
        }

        sql.append("ORDER BY e.data_prevista_devolucao ASC");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB);
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < parametros.size(); i++) {
                stmt.setObject(i + 1, parametros.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                LocalDate hoje = LocalDate.now();
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("empId", rs.getInt("emp_id"));
                    linha.put("livroId", rs.getInt("livro_id"));
                    linha.put("nome", rs.getString("nome"));
                    linha.put("matricula", rs.getString("matricula"));
                    linha.put("titulo", rs.getString("titulo"));
                    linha.put("dataEmp", rs.getDate("data_emprestimo"));
                    
                    java.sql.Date dataPrev = rs.getDate("data_prevista_devolucao");
                    linha.put("dataPrev", dataPrev);

                    double multaEstimada = 0.0;
                    if (dataPrev != null) {
                        LocalDate dataPrevLocal = dataPrev.toLocalDate();
                        if (hoje.isAfter(dataPrevLocal)) {
                            long dias = ChronoUnit.DAYS.between(dataPrevLocal, hoje);
                            multaEstimada = dias * 2.0;
                        }
                    }
                    linha.put("multaEstimada", multaEstimada);
                    listaResultados.add(linha);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao buscar empréstimos", e);
        }

        request.setAttribute("listaAtivos", listaResultados);
        request.getRequestDispatcher("admin_emprestimos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario admin = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        
        if (admin == null || !"admin".equals(admin.getTipo())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acesso negado.");
            return;
        }

        String matriculaAluno = request.getParameter("matriculaAluno");
        String livroIdStr = request.getParameter("livroId");

        if (matriculaAluno == null || livroIdStr == null || matriculaAluno.isEmpty() || livroIdStr.isEmpty()) {
            response.sendRedirect("gerenciarEmprestimos?erro=DadosIncompletos");
            return;
        }

        int livroId = Integer.parseInt(livroIdStr);

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            
            int alunoId = -1;
            String sqlAluno = "SELECT id FROM usuario WHERE matricula = ?";
            try (PreparedStatement stmtAlu = conn.prepareStatement(sqlAluno)) {
                stmtAlu.setString(1, matriculaAluno);
                try (ResultSet rsAlu = stmtAlu.executeQuery()) {
                    if (rsAlu.next()) {
                        alunoId = rsAlu.getInt("id");
                    } else {
                        response.sendRedirect("gerenciarEmprestimos?erro=AlunoNaoEncontrado");
                        return;
                    }
                }
            }

            String sqlBloqueio = "SELECT COUNT(*) FROM emprestimo WHERE usuario_id = ? AND (multa > 0 OR (data_devolucao_real IS NULL AND data_prevista_devolucao < CURRENT_DATE))";
            try (PreparedStatement stmtCheck = conn.prepareStatement(sqlBloqueio)) {
                stmtCheck.setInt(1, alunoId);
                try (ResultSet rs = stmtCheck.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect("gerenciarEmprestimos?erro=AlunoBloqueado");
                        return;
                    }
                }
            }

            conn.setAutoCommit(false);
            try {
                boolean disponivel = false;
                try (PreparedStatement stmtLivro = conn.prepareStatement("SELECT quantidade_disponivel FROM livro WHERE id = ?")) {
                    stmtLivro.setInt(1, livroId);
                    try (ResultSet rs = stmtLivro.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            disponivel = true;
                        }
                    }
                }

                if (!disponivel) {
                    throw new SQLException("Livro indisponível ou inexistente.");
                }

                LocalDate hoje = LocalDate.now();
                LocalDate devolucao = hoje.plusDays(7);

                String sqlInsert = "INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao) VALUES (?, ?, ?, ?)";
                try (PreparedStatement stmtIns = conn.prepareStatement(sqlInsert)) {
                    stmtIns.setInt(1, alunoId);
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
                response.sendRedirect("gerenciarEmprestimos?msg=Sucesso");

            } catch (SQLException e) {
                conn.rollback();
                response.sendRedirect("gerenciarEmprestimos?erro=ErroTransacao");
                e.printStackTrace();
            }

        } catch (SQLException e) {
            throw new ServletException("Erro no banco de dados", e);
        }
    }
}