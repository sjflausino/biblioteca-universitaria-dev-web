# Sistema de Gestão de Biblioteca Universitária

Este é um projeto de aplicação web em Java para gerenciamento de uma biblioteca universitária. O sistema permite o controle de acervo, gestão de usuários (alunos e administradores), realização de empréstimos com validação de estoque, cálculo automático de multas por atraso e relatórios gerenciais.

## 🚀 Tecnologias Utilizadas

O projeto foi construído utilizando as seguintes tecnologias e especificações:

* **Linguagem:** Java 11+ .
* **Framework Web:** Jakarta EE 10 (Servlets, JSP, JSTL)
* **Gerenciador de Dependências:** Apache Maven .
* **Banco de Dados:** Apache Derby (Modo Server/Network)
* **Servidor de Aplicação:** GlassFish 7.x .
* **IDE Recomendada:** NetBeans (Configurações incluídas)

## 📋 Funcionalidades

### 👤 Módulo do Aluno
* **Cadastro e Perfil:** Registro de novos alunos e atualização de dados cadastrais (senha/nome).
* **Consulta de Acervo:** Pesquisa de livros por Título, Autor ou ISBN.
* **Empréstimo:** Solicitação de empréstimo de livros (sujeito a validação de estoque e pendências).
* **Histórico:** Visualização de empréstimos ativos, datas de devolução e multas pendentes.
* **Pagamento de Multas:** Simulação de pagamento de multas para desbloqueio de novos empréstimos.

### 🛡️ Módulo Administrativo (Bibliotecário)
* **Gestão de Livros:** Cadastro, Edição e Exclusão (com proteção de integridade para livros com histórico).
* **Empréstimo Presencial:** Realização de empréstimos em nome de qualquer aluno via matrícula.
* **Devoluções:** Baixa manual de empréstimos e cálculo automático de dias de atraso.
* **Relatórios:**
    * Livros mais populares.
    * Usuários mais ativos.
    * Empréstimos em atraso com estimativa de multa.

## ⚙️ Configuração e Instalação

### 1. Banco de Dados (Apache Derby)
A aplicação espera uma conexão na porta padrão `1527`.

1.  Inicie o servidor Apache Derby.
2.  Crie um banco de dados chamado `biblioteca`.
3.  Execute o script `data.sql` localizado na raiz do projeto para criar as tabelas e popular os dados iniciais.
    * **Usuário do Banco:** `biblioteca`
    * **Senha do Banco:** `biblioteca`
    * **URL JDBC:** `jdbc:derby://localhost:1527/biblioteca`.

### 2. Executando a Aplicação
1.  Abra o projeto no NetBeans (ou IDE de preferência com suporte a Maven).
2.  Certifique-se de que o servidor GlassFish está configurado.
3.  Realize o *Clean and Build*.
4.  Execute o projeto (`Run`). O acesso será via:
    `http://localhost:8080/biblioteca`

## 🧪 Credenciais de Teste (Seed Data)

O script `data.sql` já fornece usuários pré-cadastrados para teste imediato.

| Tipo | Nome | Email | Senha | Matrícula |
| :--- | :--- | :--- | :--- | :--- |
| **Administrador** | Administrador Sistema | `admin@teste.com` | `admin` | ADM001 |
| **Aluno** | Sandro Estudante | `sandro@teste.com` | `123` | 2025001 |
| **Aluno** | Maria Silva | `maria@teste.com` | `123` | 2025002 |
| **Aluno (Inadimplente)** | João Caloteiro | `caloteiro@teste.com` | `123` | BAD001 |

## 🛡️ Regras de Negócio Implementadas

O sistema possui validações robustas no backend (`EmprestimoServlet` e `LivrosServlet`):

1.  **Estoque:** Não é possível emprestar um livro se a `quantidade_disponivel` for 0.
2.  **Duplicidade:** Um aluno não pode pegar o mesmo livro duas vezes simultaneamente.
3.  **Inadimplência:** O sistema bloqueia novos empréstimos se o aluno tiver multas em aberto ou livros atrasados.
4.  **Integridade de Dados:** Não é possível excluir um livro que já possua registros na tabela de empréstimos (Erro tratado: SQLState 23503).

## 🛠️ Scripts de Teste

O projeto inclui um script de teste automatizado (cURL) para validação rápida dos endpoints:

* `test_manual.sh`: Executa um ciclo completo de vida (Cadastro -> Login -> Empréstimo -> Devolução -> Relatórios) e valida as regras de bloqueio.

---
*Desenvolvido como parte do curso de Sistemas de Informação - UFF.*