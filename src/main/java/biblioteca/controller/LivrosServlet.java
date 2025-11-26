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

        String busca = request.getParameter("busca");
        String tipo = request.getParameter("tipo");

        List<Livro> lista = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder("SELECT * FROM livro");
        boolean temFiltro = (busca != null && !busca.trim().isEmpty());

        if (temFiltro) {
            if ("isbn".equals(tipo)) {
                sql.append(" WHERE isbn LIKE ?");
            } else if ("autor".equals(tipo)) {
                sql.append(" WHERE LOWER(autor) LIKE ?");
            } else {
                sql.append(" WHERE LOWER(titulo) LIKE ?");
            }
        }

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA); 
            PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            if (temFiltro) {
                stmt.setString(1, "%" + busca.toLowerCase() + "%");
            }

            try (ResultSet rs = stmt.executeQuery()) {
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

        String acao = request.getParameter("acao");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO, SENHA)) {
            
            if ("excluir".equals(acao)) {
                // --- Lógica de EXCLUSÃO com Proteção ---
                String idStr = request.getParameter("id");
                String sql = "DELETE FROM livro WHERE id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, Integer.parseInt(idStr));
                    stmt.executeUpdate();
                }

            } else if ("editar".equals(acao)) {
                // --- Lógica de EDIÇÃO Inteligente ---
                String idStr = request.getParameter("id");
                String titulo = request.getParameter("titulo");
                String autor = request.getParameter("autor");
                String editora = request.getParameter("editora");
                String isbn = request.getParameter("isbn");
                int novaQtdTotal = Integer.parseInt(request.getParameter("quantidade"));

                // Atualiza dados e recalcula disponibilidade:
                // Nova Disponibilidade = Velha Disponibilidade + (Novo Total - Velho Total)
                // Isso preserva os empréstimos já ativos.
                String sql = "UPDATE livro SET titulo=?, autor=?, editora=?, isbn=?, "
                           + "quantidade_disponivel = quantidade_disponivel + (? - quantidade_total), "
                           + "quantidade_total=? WHERE id=?";
                           
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, titulo);
                    stmt.setString(2, autor);
                    stmt.setString(3, editora);
                    stmt.setString(4, isbn);
                    stmt.setInt(5, novaQtdTotal); // Para o cálculo
                    stmt.setInt(6, novaQtdTotal); // Para salvar o total
                    stmt.setInt(7, Integer.parseInt(idStr));
                    stmt.executeUpdate();
                }

            } else {
                // --- Lógica de CADASTRO (Padrão) ---
                String titulo = request.getParameter("titulo");
                String autor = request.getParameter("autor");
                String editora = request.getParameter("editora");
                String isbn = request.getParameter("isbn");
                int qtd = 1;
                try { qtd = Integer.parseInt(request.getParameter("quantidade")); } catch (NumberFormatException e) {}

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
            }

        } catch (SQLException e) {
            // --- CORREÇÃO DO ERRO HTTP 500 ---
            // Código SQLState 23503 indica violação de chave estrangeira (Foreign Key) no Derby
            // Significa que tentou apagar um livro que tem empréstimos associados
            if ("23503".equals(e.getSQLState())) {
                response.sendRedirect("livros?erro=LivroComHistorico");
                return; // Interrompe para não fazer o redirect final
            }
            
            // Outros erros
            throw new ServletException("Erro na operação: " + e.getMessage());
        }

        response.sendRedirect("livros");
    }
}