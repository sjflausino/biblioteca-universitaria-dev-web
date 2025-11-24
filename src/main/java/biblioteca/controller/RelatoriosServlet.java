package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

        List<Map<String, Object>> livrosMaisEmprestados = new ArrayList<>();
        List<Map<String, Object>> emprestimosAtrasados = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {

            String sqlTop = "SELECT l.titulo, COUNT(e.id) as total FROM emprestimo e "
                    + "JOIN livro l ON e.livro_id = l.id "
                    + "GROUP BY l.titulo ORDER BY total DESC";

            try (PreparedStatement stmt = conn.prepareStatement(sqlTop); ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("titulo", rs.getString("titulo"));
                    linha.put("total", rs.getInt("total"));
                    livrosMaisEmprestados.add(linha);
                }
            }

            String sqlAtraso = "SELECT u.nome, u.email, l.titulo, e.data_prevista_devolucao FROM emprestimo e "
                    + "JOIN usuario u ON e.usuario_id = u.id "
                    + "JOIN livro l ON e.livro_id = l.id "
                    + "WHERE e.data_devolucao_real IS NULL AND e.data_prevista_devolucao < CURRENT_DATE";

            try (PreparedStatement stmt = conn.prepareStatement(sqlAtraso); ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> linha = new HashMap<>();
                    linha.put("usuario", rs.getString("nome"));
                    linha.put("email", rs.getString("email"));
                    linha.put("livro", rs.getString("titulo"));
                    linha.put("dataPrevista", rs.getDate("data_prevista_devolucao"));
                    emprestimosAtrasados.add(linha);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Erro ao gerar relatórios", e);
        }

        request.setAttribute("topLivros", livrosMaisEmprestados);
        request.setAttribute("listaAtrasos", emprestimosAtrasados);
        request.getRequestDispatcher("relatorios.jsp").forward(request, response);
    }
}
