package biblioteca.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
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

import biblioteca.model.Emprestimo;
import biblioteca.model.Livro;
import biblioteca.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/emprestimos")
public class EmprestimoServlet extends HttpServlet {

    private static final String URL = "jdbc:derby://localhost:1527/biblioteca";
    private static final String USUARIO_DB = "biblioteca";
    private static final String SENHA_DB = "biblioteca";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String acao = request.getParameter("acao");
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;

        if (usuario == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if ("gerenciar".equals(acao)) {
            // Lógica do antigo GerenciarEmprestimosServlet (Admin)
            listarTodosParaAdmin(request, response, usuario);
        } else {
            // Lógica do antigo EmprestimoServlet (Histórico do Usuário)
            listarHistoricoUsuario(request, response, usuario);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String acao = request.getParameter("acao");
        
        // Roteamento de ações
        if ("emprestar".equals(acao)) {
            realizarEmprestimoUsuario(request, response);
        } else if ("adminEmprestar".equals(acao)) {
            realizarEmprestimoAdmin(request, response);
        } else if ("devolver".equals(acao)) {
            realizarDevolucao(request, response);
        } else if ("pagarMulta".equals(acao)) {
            processarPagamentoMulta(request, response);
        } else {
            // Ação desconhecida volta para dashboard
            response.sendRedirect("dashboard.jsp");
        }
    }

    // --- MÉTODOS DE LEITURA (GET) ---

    private void listarHistoricoUsuario(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws ServletException, IOException {
        
        String sql = "SELECT e.*, l.titulo, l.autor FROM emprestimo e "
                   + "JOIN livro l ON e.livro_id = l.id "
                   + "WHERE e.usuario_id = ? ORDER BY e.data_emprestimo DESC";
        List<Emprestimo> lista = new ArrayList<>();

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, usuario.getId());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Emprestimo emp = new Emprestimo();
                    emp.setId(rs.getInt("id"));
                    emp.setDataEmprestimo(rs.getDate("data_emprestimo"));
                    emp.setDataPrevistaDevolucao(rs.getDate("data_prevista_devolucao"));
                    emp.setDataDevolucaoReal(rs.getDate("data_devolucao_real"));
                    emp.setMulta(rs.getDouble("multa"));

                    Livro l = new Livro();
                    l.setId(rs.getInt("livro_id")); 
                    l.setTitulo(rs.getString("titulo"));
                    l.setAutor(rs.getString("autor"));
                    emp.setLivro(l);

                    lista.add(emp);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Erro ao listar histórico", e);
        }

        request.setAttribute("meusEmprestimos", lista);
        request.getRequestDispatcher("historico.jsp").forward(request, response);
    }

    private void listarTodosParaAdmin(HttpServletRequest request, HttpServletResponse response, Usuario admin) 
            throws ServletException, IOException {
        
        if (!"admin".equals(admin.getTipo())) {
            response.sendRedirect("dashboard.jsp");
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
                    linha.put("dataEmp", rs.getDate("data_emprestimo"));
                    
                    java.sql.Date dataPrev = rs.getDate("data_prevista_devolucao");
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

    // --- MÉTODOS DE ESCRITA (POST) ---

    private void realizarEmprestimoUsuario(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Usuario usuario = (Usuario) request.getSession().getAttribute("usuarioLogado");
        String livroIdStr = request.getParameter("livroId");
        
        if (livroIdStr == null) { response.sendRedirect("livros?erro=LivroNaoInformado"); return; }
        int livroId = Integer.parseInt(livroIdStr);

        // Usuário comum retorna para a página de livros (acervo)
        executarLogicaEmprestimo(response, usuario.getId(), livroId, "livros", null);
    }

    private void realizarEmprestimoAdmin(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String matriculaAluno = request.getParameter("matriculaAluno");
        String livroIdStr = request.getParameter("livroId");
        
        if (matriculaAluno == null || livroIdStr == null) {
            response.sendRedirect("emprestimos?acao=gerenciar&erro=DadosIncompletos");
            return;
        }

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            int alunoId = -1;
            try (PreparedStatement stmt = conn.prepareStatement("SELECT id FROM usuario WHERE matricula = ?")) {
                stmt.setString(1, matriculaAluno);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) alunoId = rs.getInt("id");
                    else {
                        response.sendRedirect("emprestimos?acao=gerenciar&erro=AlunoNaoEncontrado");
                        return;
                    }
                }
            }
            // Admin retorna para a página de gerenciamento
            executarLogicaEmprestimo(response, alunoId, Integer.parseInt(livroIdStr), "emprestimos?acao=gerenciar", "admin");
            
        } catch (SQLException e) { throw new ServletException(e); }
    }

    // Lógica comum para registrar empréstimo no banco
    private void executarLogicaEmprestimo(HttpServletResponse response, int usuarioId, int livroId, String urlSucesso, String origem) 
            throws IOException, ServletException {
        
        // CORREÇÃO CRÍTICA: Verifica se a URL já possui parâmetros para usar o separador correto
        String separador = urlSucesso.contains("?") ? "&" : "?";

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            
            // 1. Verifica bloqueios (Multas ou Atrasos)
            String sqlBloqueio = "SELECT COUNT(*) FROM emprestimo WHERE usuario_id = ? AND (multa > 0 OR (data_devolucao_real IS NULL AND data_prevista_devolucao < CURRENT_DATE))";
            try (PreparedStatement stmt = conn.prepareStatement(sqlBloqueio)) {
                stmt.setInt(1, usuarioId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect(urlSucesso + separador + "erro=Bloqueado");
                        return;
                    }
                }
            }

            // 2. Verifica duplicidade (Mesmo livro não devolvido)
            String sqlDup = "SELECT COUNT(*) FROM emprestimo WHERE usuario_id = ? AND livro_id = ? AND data_devolucao_real IS NULL";
            try (PreparedStatement stmt = conn.prepareStatement(sqlDup)) {
                stmt.setInt(1, usuarioId);
                stmt.setInt(2, livroId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect(urlSucesso + separador + "erro=LivroJaComUsuario");
                        return;
                    }
                }
            }

            conn.setAutoCommit(false);
            try {
                // 3. Verifica Disponibilidade no Estoque e Insere
                boolean disponivel = false;
                try (PreparedStatement stmt = conn.prepareStatement("SELECT quantidade_disponivel FROM livro WHERE id = ?")) {
                    stmt.setInt(1, livroId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) disponivel = true;
                    }
                }

                if (!disponivel) throw new SQLException("Livro Indisponivel");

                LocalDate hoje = LocalDate.now();
                LocalDate devolucao = hoje.plusDays(7); // Prazo de 7 dias
                
                String sqlIns = "INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_prevista_devolucao) VALUES (?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sqlIns)) {
                    stmt.setInt(1, usuarioId);
                    stmt.setInt(2, livroId);
                    stmt.setDate(3, java.sql.Date.valueOf(hoje));
                    stmt.setDate(4, java.sql.Date.valueOf(devolucao));
                    stmt.executeUpdate();
                }

                try (PreparedStatement stmt = conn.prepareStatement("UPDATE livro SET quantidade_disponivel = quantidade_disponivel - 1 WHERE id = ?")) {
                    stmt.setInt(1, livroId);
                    stmt.executeUpdate();
                }

                conn.commit();
                response.sendRedirect(urlSucesso + separador + "msg=EmprestimoSucesso");

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            throw new ServletException("Erro ao processar empréstimo", e);
        }
    }

    private void realizarDevolucao(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int empId = Integer.parseInt(request.getParameter("emprestimoId"));
        int livroId = Integer.parseInt(request.getParameter("livroId"));
        String origem = request.getParameter("origem");

        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            conn.setAutoCommit(false);
            try {
                double multa = 0.0;
                // Calcula multa se houver atraso
                try (PreparedStatement stmt = conn.prepareStatement("SELECT data_prevista_devolucao FROM emprestimo WHERE id = ?")) {
                    stmt.setInt(1, empId);
                    try (ResultSet rs = stmt.executeQuery()) {
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

                // Atualiza o empréstimo com a data real de devolução e a multa
                try (PreparedStatement stmt = conn.prepareStatement("UPDATE emprestimo SET data_devolucao_real = CURRENT_DATE, multa = ? WHERE id = ?")) {
                    stmt.setDouble(1, multa);
                    stmt.setInt(2, empId);
                    stmt.executeUpdate();
                }

                // Devolve o livro ao estoque (+1)
                try (PreparedStatement stmt = conn.prepareStatement("UPDATE livro SET quantidade_disponivel = quantidade_disponivel + 1 WHERE id = ?")) {
                    stmt.setInt(1, livroId);
                    stmt.executeUpdate();
                }

                conn.commit();

                if ("admin".equals(origem)) {
                    response.sendRedirect("emprestimos?acao=gerenciar&msg=DevolucaoSucesso");
                } else {
                    response.sendRedirect("emprestimos?msg=DevolucaoSucesso");
                }

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { throw new ServletException(e); }
    }

    private void processarPagamentoMulta(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int empId = Integer.parseInt(request.getParameter("emprestimoId"));
        try (Connection conn = DriverManager.getConnection(URL, USUARIO_DB, SENHA_DB)) {
            try (PreparedStatement stmt = conn.prepareStatement("UPDATE emprestimo SET multa = 0.0 WHERE id = ?")) {
                stmt.setInt(1, empId);
                stmt.executeUpdate();
            }
            response.sendRedirect("emprestimos?msg=MultaPaga");
        } catch (SQLException e) { throw new ServletException(e); }
    }
}