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

## 🗂️ Estrutura do Projeto

```
lib/
├── app.dart                  # MaterialApp e tema global
├── main.dart                 # Bootstrap + inicialização do Supabase
├── core/
│   ├── config/               # Leitura do .env / modo demonstração
│   ├── constants/            # Imagens institucionais
│   ├── theme/                # Paleta Dark & Gold, tipografia e ThemeData
│   └── utils/                # Formatadores (data/moeda) e mensagens de erro
├── data/demo_store.dart      # Dados locais para o modo demonstração
├── models/                   # Service, Barber e Appointment
├── repositories/             # Acesso ao Supabase (com fallback local)
├── providers/                # Providers Riverpod
├── screens/                  # Home, Serviços, Detalhes, Horário, Confirmação e Agendamentos
└── widgets/                  # Componentes reutilizáveis do design system
supabase/schema.sql           # DDL, RLS, triggers e seeds
```

## 🛠️ Como Executar o Projeto

### 1. Configurar o Supabase

1. Crie um projeto em [supabase.com](https://supabase.com).
2. Abra o **SQL Editor** e execute o conteúdo de [`supabase/schema.sql`](supabase/schema.sql).
   O script cria as tabelas `services`, `barbers` e `appointments`, o trigger que calcula
   `end_time`/`total_price`, o bloqueio de conflitos de horário, as políticas de acesso
   e os dados iniciais de teste.
3. Em **Project Settings > API**, copie a **URL** e a **chave publicável (anon)**.

### 2. Configurar credenciais

Edite o arquivo `.env` na raiz:

```env
SUPABASE_URL=https://SEU-PROJETO.supabase.co
SUPABASE_ANON_KEY=SUA_ANON_KEY_AQUI
```

> Enquanto os valores permanecerem com os placeholders, o app inicia em **modo
> demonstração**, usando dados locais em memória — útil para avaliar o layout e o
> fluxo completo sem backend.

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

## 🔐 Observações de segurança

As políticas RLS do script liberam leitura do catálogo e criação/consulta de
agendamentos para o papel `anon`, pois esta versão não possui autenticação.
Para produção, vincule `appointments` a um `user_id` autenticado e restrinja as
políticas ao próprio usuário.
