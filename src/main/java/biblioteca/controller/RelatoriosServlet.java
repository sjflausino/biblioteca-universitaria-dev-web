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

@WebServlet("/relatorios")
public class RelatoriosServlet extends HttpServlet {

    private Connection conexao = null;

    @Override
    public void init() throws ServletException {
        try {
            conexao = DriverManager.getConnection("jdbc:derby://localhost:1527/biblioteca", "biblioteca", "biblioteca");
        } catch (SQLException ex) {
            throw new ServletException("Erro ao conectar no banco: " + ex.getMessage());
        }
    }

    @Override
    public void destroy() {
        try {
            if (conexao != null && !conexao.isClosed()) {
                conexao.close();
            }
        } catch (SQLException ex) {
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Usuario u = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        
        if (u == null || !"admin".equals(u.getTipo())) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, Object>> livrosMaisEmprestados = new ArrayList<>();
        List<Map<String, Object>> usuariosMaisAtivos = new ArrayList<>();
        List<Map<String, Object>> emprestimosAtrasados = new ArrayList<>();

        try {
            String sqlTop = "SELECT l.titulo, l.autor, COUNT(e.id) as total FROM emprestimo e "
                    + "JOIN livro l ON e.livro_id = l.id "
                    + "GROUP BY l.titulo, l.autor ORDER BY total DESC";
            
            try (PreparedStatement stmt = conexao.prepareStatement(sqlTop); ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("titulo", rs.getString("titulo"));
                    linha.put("autor", rs.getString("autor"));
                    linha.put("total", rs.getInt("total"));
                    livrosMaisEmprestados.add(linha);
                }
            }

            String sqlTopUsuarios = "SELECT u.nome, u.matricula, COUNT(e.id) as total FROM emprestimo e "
                                  + "JOIN usuario u ON e.usuario_id = u.id "
                                  + "GROUP BY u.nome, u.matricula ORDER BY total DESC";
            
            try (PreparedStatement stmt = conexao.prepareStatement(sqlTopUsuarios); ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("nome", rs.getString("nome"));
                    linha.put("matricula", rs.getString("matricula"));
                    linha.put("total", rs.getInt("total"));
                    usuariosMaisAtivos.add(linha);
                }
            }

            String sqlAtraso = "SELECT u.nome, u.matricula, u.email, l.titulo, e.data_prevista_devolucao FROM emprestimo e "
                    + "JOIN usuario u ON e.usuario_id = u.id "
                    + "JOIN livro l ON e.livro_id = l.id "
                    + "WHERE e.data_devolucao_real IS NULL AND e.data_prevista_devolucao < CURRENT_DATE";

            try (PreparedStatement stmt = conexao.prepareStatement(sqlAtraso); ResultSet rs = stmt.executeQuery()) {
                LocalDate hoje = LocalDate.now();
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("usuario", rs.getString("nome"));
                    linha.put("matricula", rs.getString("matricula"));
                    linha.put("email", rs.getString("email"));
                    linha.put("livro", rs.getString("titulo"));
                    
                    java.sql.Date dataPrevista = rs.getDate("data_prevista_devolucao");
                    linha.put("dataPrevista", dataPrevista);

                    long diasAtraso = 0;
                    double multaEstimada = 0.0;
                    
                    if (dataPrevista != null) {
                        LocalDate dataPrevLocal = dataPrevista.toLocalDate();
                        if (hoje.isAfter(dataPrevLocal)) {
                            diasAtraso = ChronoUnit.DAYS.between(dataPrevLocal, hoje);
                            multaEstimada = diasAtraso * 2.0;
                        }
                    }
                    linha.put("diasAtraso", diasAtraso);
                    linha.put("multaEstimada", multaEstimada);

                    emprestimosAtrasados.add(linha);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Erro ao gerar relatórios", e);
        }

        request.setAttribute("topLivros", livrosMaisEmprestados);
        request.setAttribute("topUsuarios", usuariosMaisAtivos);
        request.setAttribute("listaAtrasos", emprestimosAtrasados);
        
        request.getRequestDispatcher("relatorios.jsp").forward(request, response);
    }
}