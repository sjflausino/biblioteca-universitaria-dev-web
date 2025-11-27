package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

        // Roteamento
        if ("perfil".equals(acao)) {
            if (usuarioLogado == null) {
                response.sendRedirect("login.jsp");
            } else {
                request.getRequestDispatcher("perfil.jsp").forward(request, response);
            }
        } else if ("cadastro".equals(acao)) {
            request.getRequestDispatcher("cadastro.jsp").forward(request, response);
            
        // --- NOVA LÓGICA: GERENCIAR (ADMIN) ---
        } else if ("gerenciar".equals(acao)) {
            listarUsuariosParaAdmin(request, response, usuarioLogado);
            
        } else {
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
            
        // --- NOVAS LÓGICAS DE ADMIN ---
        } else if ("editarAdmin".equals(acao)) {
            processarEdicaoAdmin(request, response);
        } else if ("excluir".equals(acao)) {
            processarExclusao(request, response);
            
        } else {
            response.sendRedirect("index.html");
        }
    }

    // --- MÉTODOS EXISTENTES (Cadastro e Atualização Pessoal) ---
    // (Mantenha os métodos processarCadastro e processarAtualizacao como estão no original)
    // ... [CÓDIGO OMITIDO PARA BREVIDADE, MANTER O QUE JÁ EXISTE NAS LINHAS 232-249] ...
    
    // Vou reincluir versões simplificadas aqui apenas para contexto se você copiar e colar tudo:
    private void processarCadastro(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ... (Lógica original de cadastro) ...
        // Se precisar do código completo desta parte, verifique as linhas 232-240 do seu arquivo original.
         try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            String sql = "INSERT INTO usuario (nome, email, matricula, senha, tipo) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, request.getParameter("nome"));
                stmt.setString(2, request.getParameter("email"));
                stmt.setString(3, request.getParameter("matricula"));
                stmt.setString(4, request.getParameter("senha"));
                String tipo = request.getParameter("tipo");
                stmt.setString(5, tipo != null ? tipo : "aluno");
                stmt.executeUpdate();
            }
            response.sendRedirect("login.jsp?msg=cadastrado");
        } catch (SQLException e) {
            request.setAttribute("erro", "Erro ao cadastrar: " + e.getMessage());
            request.getRequestDispatcher("cadastro.jsp").forward(request, response);
        }
    }

    private void processarAtualizacao(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ... (Lógica original de atualização de perfil pessoal) ...
         HttpSession session = request.getSession(false);
        Usuario usuarioLogado = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        if (usuarioLogado == null) { response.sendRedirect("login.jsp"); return; }

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            String sql = "UPDATE usuario SET nome = ?, senha = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, request.getParameter("nome"));
                stmt.setString(2, request.getParameter("senha"));
                stmt.setInt(3, usuarioLogado.getId());
                stmt.executeUpdate();
            }
            usuarioLogado.setNome(request.getParameter("nome"));
            usuarioLogado.setSenha(request.getParameter("senha"));
            session.setAttribute("usuarioLogado", usuarioLogado);
            request.setAttribute("msg", "Perfil atualizado com sucesso!");
            request.getRequestDispatcher("perfil.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }


    // --- NOVOS MÉTODOS PARA O ADMIN ---

    private void listarUsuariosParaAdmin(HttpServletRequest request, HttpServletResponse response, Usuario admin) 
            throws ServletException, IOException {
        
        if (admin == null || !"admin".equals(admin.getTipo())) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT * FROM usuario ORDER BY nome";

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB);
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setNome(rs.getString("nome"));
                u.setEmail(rs.getString("email"));
                u.setMatricula(rs.getString("matricula"));
                u.setTipo(rs.getString("tipo"));
                // Não precisamos expor a senha na listagem
                lista.add(u);
            }

        } catch (SQLException e) {
            throw new ServletException("Erro ao listar usuários", e);
        }

        request.setAttribute("listaUsuarios", lista);
        request.getRequestDispatcher("admin_usuarios.jsp").forward(request, response);
    }

    private void processarExclusao(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario admin = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        
        if (admin == null || !"admin".equals(admin.getTipo())) {
            response.sendRedirect("login.jsp");
            return;
        }

        int idParaExcluir = Integer.parseInt(request.getParameter("id"));

        // Proteção: Admin não pode se excluir
        if (idParaExcluir == admin.getId()) {
            response.sendRedirect("usuario?acao=gerenciar&erro=AutoExclusao");
            return;
        }

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            String sql = "DELETE FROM usuario WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, idParaExcluir);
                stmt.executeUpdate();
            }
            response.sendRedirect("usuario?acao=gerenciar&msg=ExcluidoSucesso");
            
        } catch (SQLException e) {
            // Tratamento para chave estrangeira (se usuário tem empréstimos)
            if ("23503".equals(e.getSQLState())) {
                response.sendRedirect("usuario?acao=gerenciar&erro=UsuarioComHistorico");
            } else {
                throw new ServletException("Erro ao excluir usuário", e);
            }
        }
    }

    private void processarEdicaoAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verifica permissão
        HttpSession session = request.getSession(false);
        Usuario admin = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;
        if (admin == null || !"admin".equals(admin.getTipo())) {
            response.sendRedirect("login.jsp");
            return;
        }

        int id = Integer.parseInt(request.getParameter("id"));
        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String matricula = request.getParameter("matricula");
        String tipo = request.getParameter("tipo");
        String novaSenha = request.getParameter("senha");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            
            // Query dinâmica: Atualiza senha apenas se for preenchida
            StringBuilder sql = new StringBuilder("UPDATE usuario SET nome=?, email=?, matricula=?, tipo=?");
            if (novaSenha != null && !novaSenha.trim().isEmpty()) {
                sql.append(", senha=?");
            }
            sql.append(" WHERE id=?");

            try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
                stmt.setString(1, nome);
                stmt.setString(2, email);
                stmt.setString(3, matricula);
                stmt.setString(4, tipo);
                
                int index = 5;
                if (novaSenha != null && !novaSenha.trim().isEmpty()) {
                    stmt.setString(index++, novaSenha);
                }
                stmt.setInt(index, id);
                
                stmt.executeUpdate();
            }
            response.sendRedirect("usuario?acao=gerenciar&msg=EditadoSucesso");

        } catch (SQLException e) {
             throw new ServletException("Erro ao editar usuário", e);
        }
    }
}