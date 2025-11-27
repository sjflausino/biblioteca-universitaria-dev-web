<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Gerenciar Usuários - Biblioteca</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>
    <div class="admin-container">
        <a href="dashboard.jsp" class="link-voltar">← Voltar ao Painel</a>
        <h1>Gerenciar Usuários</h1>

        <c:if test="${param.msg == 'ExcluidoSucesso'}">
            <div class="msg-sucesso">Usuário excluído com sucesso!</div>
        </c:if>
        <c:if test="${param.msg == 'EditadoSucesso'}">
            <div class="msg-sucesso">Dados do usuário atualizados!</div>
        </c:if>
        <c:if test="${param.erro == 'AutoExclusao'}">
            <div class="msg-erro">Erro: Você não pode excluir sua própria conta.</div>
        </c:if>
        <c:if test="${param.erro == 'UsuarioComHistorico'}">
            <div class="msg-erro">Erro: Este usuário possui empréstimos registrados e não pode ser excluído.</div>
        </c:if>

        <div class="mb-15">
            <a href="cadastro.jsp?adminMode=true">
                <button class="btn-adicionar">+ Cadastrar Novo Usuário</button>
            </a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nome</th>
                    <th>Matrícula</th>
                    <th>Email</th>
                    <th>Tipo</th>
                    <th style="width: 140px;">Ações</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${listaUsuarios}">
                    <tr>
                        <td>${u.id}</td>
                        <td>${u.nome}</td>
                        <td>${u.matricula}</td>
                        <td>${u.email}</td>
                        <td>
                            <c:if test="${u.tipo == 'admin'}"><span class="tipo-admin">Admin</span></c:if>
                            <c:if test="${u.tipo != 'admin'}">Aluno</c:if>
                        </td>
                        <td style="text-align: center;">
                            <a href="editar_usuario.jsp?id=${u.id}&nome=${u.nome}&email=${u.email}&matricula=${u.matricula}&tipo=${u.tipo}" class="btn-editar">Editar</a>
                            
                            <c:if test="${u.id != sessionScope.usuarioLogado.id}">
                                <form action="usuario" method="POST" onsubmit="return confirm('Tem certeza que deseja excluir o usuário ${u.nome}?');">
                                    <input type="hidden" name="acao" value="excluir">
                                    <input type="hidden" name="id" value="${u.id}">
                                    <button type="submit" class="btn-excluir-admin">X</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    <jsp:include page="footer.jsp"/>
</body>
</html>
