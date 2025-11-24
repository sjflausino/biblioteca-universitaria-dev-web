package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import biblioteca.model.Livro;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/livros")
public class LivrosServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO = "biblioteca";
    private static final String SENHA = "biblioteca";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Livro> lista = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA); 
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM livro"); 
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Livro livro = new Livro();
                livro.setId(rs.getInt("id"));
                livro.setTitulo(rs.getString("titulo"));
                livro.setAutor(rs.getString("autor"));
                livro.setEditora(rs.getString("editora"));
                livro.setIsbn(rs.getString("isbn"));
                livro.setQuantidadeDisponivel(rs.getInt("quantidade_disponivel"));
                lista.add(livro);
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao listar livros", e);
        }

        request.setAttribute("listaLivros", lista);
        request.getRequestDispatcher("livros.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String titulo = request.getParameter("titulo");
        if (titulo == null || titulo.trim().isEmpty()) {
             response.sendRedirect("livros?erro=DadosInvalidos");
             return;
        }

        String autor = request.getParameter("autor");
        String editora = request.getParameter("editora");
        String isbn = request.getParameter("isbn");
        
        int qtd = 1;
        try {
            qtd = Integer.parseInt(request.getParameter("quantidade"));
        } catch (NumberFormatException e) {
            qtd = 1; 
        }

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {
            String sql = "INSERT INTO livro (titulo, autor, editora, isbn, quantidade_total, quantidade_disponivel) VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, titulo);
                stmt.setString(2, autor);
                stmt.setString(3, editora);
                stmt.setString(4, isbn);
                stmt.setInt(5, qtd);
                stmt.setInt(6, qtd);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao cadastrar livro: " + e.getMessage());
        }

        response.sendRedirect("livros");
    }
}