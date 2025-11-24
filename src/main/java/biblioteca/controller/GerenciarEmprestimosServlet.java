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
                    
                    java.sql.Date dataEmp = rs.getDate("data_emprestimo");
                    java.sql.Date dataPrev = rs.getDate("data_prevista_devolucao");
                    
                    linha.put("dataEmp", dataEmp);
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
}