package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.temporal.ChronoUnit;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/devolucao")
public class DevolucaoServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO = "biblioteca";
    private static final String SENHA = "biblioteca";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String empIdStr = request.getParameter("emprestimoId");
        String livroIdStr = request.getParameter("livroId");

        if (empIdStr == null || livroIdStr == null) {
            response.sendRedirect("emprestimos?erro=DadosInvalidos");
            return;
        }

        int empId = Integer.parseInt(empIdStr);
        int livroId = Integer.parseInt(livroIdStr);

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {
            conn.setAutoCommit(false);
            try {
                double multa = 0.0;
                try (PreparedStatement stmtGet = conn.prepareStatement("SELECT data_prevista_devolucao FROM emprestimo WHERE id = ?")) {
                    stmtGet.setInt(1, empId);
                    try (ResultSet rs = stmtGet.executeQuery()) {
                        if (rs.next()) {
                            Date prevista = rs.getDate(1);
                            Date atual = new Date(System.currentTimeMillis());
                            if (atual.after(prevista)) {
                                long dias = ChronoUnit.DAYS.between(prevista.toLocalDate(), atual.toLocalDate());
                                multa = dias * 2.00;
                            }
                        }
                    }
                }

                try (PreparedStatement stmtUpdEmp = conn.prepareStatement("UPDATE emprestimo SET data_devolucao_real = CURRENT_DATE, multa = ? WHERE id = ?")) {
                    stmtUpdEmp.setDouble(1, multa);
                    stmtUpdEmp.setInt(2, empId);
                    stmtUpdEmp.executeUpdate();
                }

                try (PreparedStatement stmtUpdLivro = conn.prepareStatement("UPDATE livro SET quantidade_disponivel = quantidade_disponivel + 1 WHERE id = ?")) {
                    stmtUpdLivro.setInt(1, livroId);
                    stmtUpdLivro.executeUpdate();
                }

                conn.commit();
                response.sendRedirect("emprestimos");

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao processar devolução", e);
        }
    }
}