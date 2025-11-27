<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${empty sessionScope.usuarioLogado or sessionScope.usuarioLogado.tipo != 'admin'}">
    <c:redirect url="login.jsp"/>
</c:if>

<!DOCTYPE html>
<html>
<head>
    <title>Gerenciar Usuários</title>
    <link rel="stylesheet" href="css/common.css">
    <style>
        .btn-editar { background-color: #ffc107; color: black; text-decoration: none; padding: 5px 10px; border-radius: 3px; border: 1px solid #e0a800; font-size: 13px; }
        .btn-excluir { background-color: #dc3545; color: white; padding: 5px 10px; border: none; border-radius: 3px; cursor: pointer; font-size: 13px; }
        .tipo-admin { font-weight: bold; color: #007bff; }
    </style>
</head>
<body>
    <a href="dashboard.jsp">Voltar ao Painel</a>
    <h1>Gerenciar Usuários do Sistema</h1>

    <c:if test="${param.msg == 'ExcluidoSucesso'}"><h3 class="msg-sucesso" style="color:green">Usuário excluído com sucesso!</h3></c:if>
    <c:if test="${param.msg == 'EditadoSucesso'}"><h3 class="msg-sucesso" style="color:green">Dados do usuário atualizados!</h3></c:if>
    <c:if test="${param.erro == 'AutoExclusao'}"><h3 class="msg-erro" style="color:red">Erro: Você não pode excluir sua própria conta.</h3></c:if>
    <c:if test="${param.erro == 'UsuarioComHistorico'}"><h3 class="msg-erro" style="color:red">Erro: Este usuário possui empréstimos registrados e não pode ser excluído.</h3></c:if>

    <div style="margin-bottom: 15px;">
        <a href="cadastro.jsp?adminMode=true"><button>+ Cadastrar Novo Usuário</button></a>
    </div>

    <table border="1">
        <thead>
            <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>Matrícula</th>
                <th>Email</th>
                <th>Tipo</th>
                <th style="width: 150px;">Ações</th>
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
                        
                        <%-- Botão Editar --%>
                        <a href="editar_usuario.jsp?id=${u.id}&nome=${u.nome}&email=${u.email}&matricula=${u.matricula}&tipo=${u.tipo}" class="btn-editar">Editar</a>

                        <%-- Botão Excluir (Exceto se for o próprio admin) --%>
                        <c:if test="${u.id != sessionScope.usuarioLogado.id}">
                            <form action="usuario" method="POST" onsubmit="return confirm('Tem certeza que deseja excluir o usuário ${u.nome}?');" style="display:inline;">
                                <input type="hidden" name="acao" value="excluir">
                                <input type="hidden" name="id" value="${u.id}">
                                <button type="submit" class="btn-excluir">X</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <jsp:include page="footer.jsp"/>
</body>
</html>