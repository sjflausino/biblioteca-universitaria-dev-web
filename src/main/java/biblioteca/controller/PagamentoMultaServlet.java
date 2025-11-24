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

@WebServlet("/pagarMulta")
public class PagamentoMultaServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO = "biblioteca";
    private static final String SENHA = "biblioteca";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // ID do empréstimo que gerou a multa
        int emprestimoId = Integer.parseInt(request.getParameter("emprestimoId"));

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {
            // Zera a multa, considerando-a paga
            String sql = "UPDATE emprestimo SET multa = 0.0 WHERE id = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, emprestimoId);
                stmt.executeUpdate();
            }
            
            response.sendRedirect("emprestimos"); // Volta para o histórico
            
        } catch (SQLException e) {
            throw new ServletException("Erro ao processar pagamento", e);
        }
    }
}