package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import biblioteca.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/usuario")
public class UsuarioServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO_DB = "biblioteca";
    private static final String SENHA_DB = "biblioteca";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String acao = request.getParameter("acao");
        HttpSession session = request.getSession(false);
        Usuario usuarioLogado = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;

        // Roteamento simples via GET
        if ("perfil".equals(acao)) {
            if (usuarioLogado == null) {
                response.sendRedirect("login.jsp");
            } else {
                request.getRequestDispatcher("perfil.jsp").forward(request, response);
            }
        } else if ("cadastro".equals(acao)) {
            request.getRequestDispatcher("cadastro.jsp").forward(request, response);
        } else {
            // Default: Redireciona para dashboard ou login
            response.sendRedirect(usuarioLogado != null ? "dashboard.jsp" : "login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String acao = request.getParameter("acao");

        if ("cadastrar".equals(acao)) {
            processarCadastro(request, response);
        } else if ("atualizar".equals(acao)) {
            processarAtualizacao(request, response);
        } else {
            response.sendRedirect("index.html"); // Ação desconhecida
        }
    }

    private void processarCadastro(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String matricula = request.getParameter("matricula");
        String senha = request.getParameter("senha");
        String tipo = request.getParameter("tipo");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
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
            // Mantém os dados preenchidos em caso de erro (opcional)
            request.setAttribute("nome", nome);
            request.setAttribute("email", email);
            request.getRequestDispatcher("cadastro.jsp").forward(request, response);
        }
    }

    private void processarAtualizacao(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario usuarioLogado = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;

        if (usuarioLogado == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String novoNome = request.getParameter("nome");
        String novaSenha = request.getParameter("senha");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            String sql = "UPDATE usuario SET nome = ?, senha = ? WHERE id = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, novoNome);
                stmt.setString(2, novaSenha);
                stmt.setInt(3, usuarioLogado.getId());
                stmt.executeUpdate();
            }

            // Atualiza a sessão
            usuarioLogado.setNome(novoNome);
            usuarioLogado.setSenha(novaSenha);
            session.setAttribute("usuarioLogado", usuarioLogado);

            request.setAttribute("msg", "Perfil atualizado com sucesso!");
            request.getRequestDispatcher("perfil.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("erro", "Erro ao atualizar: " + e.getMessage());
            request.getRequestDispatcher("perfil.jsp").forward(request, response);
        }
    }
}