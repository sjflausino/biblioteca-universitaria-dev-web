package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import biblioteca.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

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
        if ("logout".equals(request.getParameter("acao"))) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String sql = "SELECT * FROM usuario WHERE email = ? AND senha = ?";
        
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {

            stmt.setString(1, request.getParameter("email"));
            stmt.setString(2, request.getParameter("senha"));

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario();
                    u.setId(rs.getInt("id"));
                    u.setNome(rs.getString("nome"));
                    u.setEmail(rs.getString("email"));
                    u.setTipo(rs.getString("tipo"));

                    request.getSession().setAttribute("usuarioLogado", u);
                    response.sendRedirect("dashboard.jsp");
                } else {
                    request.setAttribute("erro", "Usuário ou Senha incorretos");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Erro de conexão ou consulta", e);
        }
    }
}