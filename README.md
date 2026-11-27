# 💈 BlackMustache

Aplicativo mobile oficial de agendamento para a barbearia **Black Mustache**. Desenvolvido com foco em uma experiência visual sofisticada (Dark & Gold UI) e navegação fluida para que clientes escolham seus serviços, barbeiros e horários com praticidade

## 📱 Telas e Fluxo do Aplicativo

O fluxo principal do aplicativo é dividido em 5 etapas intuitivas

1. **01 - Início:** Apresentação da marca, atalho rápido para agendamento e vitrine de serviços em destaque
2. **02 - Nossos Serviços:** Catálogo completo (Corte tradicional, Corte degradê, Barba, Corte + barba) com fotos, descrição, duração e valores
3. **03 - Detalhes do Serviço:** Resumo do serviço selecionado e escolha do profissional (com especialidade de cada barbeiro)
4. **04 - Escolha de Horário:** Calendário interativo e grade de horários disponíveis em tempo real para o barbeiro escolhido
5. **05 - Agendamento Confirmado:** Comprovante visual com resumo completo (serviço, profissional, data, faixa de horário e valor)

*(Além da barra de navegação inferior com acesso rápido entre **Início** e **Agendamentos**.)*

## 🚀 Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)**: Framework principal para construção da interface mobile multiplataforma (Android e iOS).
- **[Supabase](https://supabase.com/)**: Backend-as-a-Service (BaaS) utilizando PostgreSQL para armazenamento de serviços, barbeiros, disponibilidade e agendamentos em tempo real.
- **Riverpod**: Gerenciamento de estado e injeção de dependências.
- **google_fonts**: Tipografia Playfair Display (títulos) e Inter (textos).
- **flutter_dotenv / intl**: Configuração de credenciais e formatação de datas e moeda (pt_BR).

## ✨ Funcionalidades

- [x] **Catálogo Dinâmico:** Listagem de serviços e destaques carregados diretamente do banco de dados.
- [x] **Seleção de Profissional:** Escolha de barbeiros com exibição de perfil e especialidade.
- [x] **Agenda em Tempo Real:** Consulta de datas e horários livres filtrados por barbeiro e duração do serviço.
- [x] **Confirmação e Histórico:** Registro de reservas no Supabase e consulta na aba *Agendamentos*.
- [x] **Autenticação:** Cadastro e login com e-mail e senha via Supabase Auth, sessão persistida e botão *Sair*.

## 🗂️ Estrutura do Projeto

```
lib/
├── app.dart                  # MaterialApp e tema global
├── main.dart                 # Bootstrap + inicialização do Supabase
├── core/
│   ├── config/               # Leitura do .env / credenciais do Supabase
│   ├── constants/            # Imagens institucionais
│   ├── theme/                # Paleta Dark & Gold, tipografia e ThemeData
│   └── utils/                # Formatadores (data/moeda) e mensagens de erro
├── data/demo_store.dart      # Dados locais para o modo demonstração
├── models/                   # Service, Barber e Appointment
├── repositories/             # Acesso ao Supabase (com fallback local)
├── providers/                # Providers Riverpod (inclui authStateProvider)
├── screens/                  # Login, AuthGate, Home, Serviços, Detalhes, Horário,
│                             # Confirmação e Agendamentos
└── widgets/                  # Componentes reutilizáveis (inclui LogoutButton)
supabase/schema.sql           # DDL, RLS, triggers e seeds
```

## 🛠️ Como Executar o Projeto

### 1. Configurar o Supabase

1. Crie um projeto em [supabase.com](https://supabase.com).
2. Abra o **SQL Editor** e execute o conteúdo de [`supabase/schema.sql`](supabase/schema.sql).
   O script cria as tabelas `services`, `barbers` e `appointments` (com `user_id`),
   o trigger que calcula `end_time`/`total_price`, o bloqueio de conflitos de horário,
   as políticas de RLS por usuário e os dados iniciais do catálogo.
3. Em **Authentication > Providers > Email**, mantenha o provedor habilitado.
   Desative **Confirm email** se quiser que o usuário entre logo após se cadastrar;
   se mantiver ativo, ele precisará clicar no link enviado por e-mail.
   O botão **Cadastre-se** da tela de login cria a conta direto no app; criar
   usuários em **Authentication > Users** continua opcional.
4. Em **Project Settings > API**, copie a **URL do projeto** e a **publishable key**.

### 2. Configurar credenciais

Edite o arquivo `.env` na raiz do projeto:

```env
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_ANON_KEY=SUA_PUBLISHABLE_KEY_AQUI
```

> Use a URL base (`https://SEU-PROJETO.supabase.co`), sem o sufixo `/rest/v1/`.
> Nunca coloque a `service_role key` no app. Sem credenciais válidas, a tela de
> login exibe um aviso e o acesso ao app permanece bloqueado.

### 3. Rodar o app

```bash
flutter pub get
flutter run
```

Para gerar a versão web:

```bash
flutter build web
```

### 4. Testes e análise

```bash
flutter analyze
flutter test
```

## 🔐 Autenticação e segurança

O app usa **Supabase Auth** com e-mail e senha (`supabase_flutter`). A sessão é
persistida pelo SDK e monitorada pelo provider `authStateProvider`: sem sessão
válida, `AuthGate` exibe a tela de login; após `signOut()`, o app volta para o login.

As políticas RLS liberam apenas a leitura do catálogo para usuários anônimos.
Agendamentos exigem `authenticated` e `user_id = auth.uid()`, portanto cada
cliente vê e altera somente os seus. A `service_role key` nunca deve ser usada no app.
