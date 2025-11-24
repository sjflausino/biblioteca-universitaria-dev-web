package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cadastroUsuario")
public class CadastroUsuarioServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO = "biblioteca";
    private static final String SENHA = "biblioteca";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String matricula = request.getParameter("matricula");
        String senha = request.getParameter("senha");
        String tipo = request.getParameter("tipo");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {

            String sql = "INSERT INTO usuario (nome, email, matricula, senha, tipo) VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, nome);
                stmt.setString(2, email);
                stmt.setString(3, matricula);
                stmt.setString(4, senha);
                stmt.setString(5, tipo != null ? tipo : "aluno");

                stmt.executeUpdate();
            }

            response.sendRedirect("login.jsp?msg=cadastrado");

        } catch (SQLException e) {
            request.setAttribute("erro", "Erro ao cadastrar: " + e.getMessage());
            request.getRequestDispatcher("cadastro.jsp").forward(request, response);
        }
    }
}
