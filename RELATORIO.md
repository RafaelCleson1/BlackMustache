# Relatório de Entrega - Black Mustache

Repositório: https://github.com/RafaelCleson1/BlackMustache.git (branch `main`)

## Visão geral

Aplicativo Flutter de agendamento para a barbearia Black Mustache, com interface Dark & Gold, catálogo de serviços, escolha de profissional, seleção de horário e histórico de reservas. O backend usa Supabase (PostgreSQL + Auth).

## Telas implementadas

- `lib/screens/home_screen.dart` - Início, apresentação da marca, atalho de agendamento e destaques.
- `lib/screens/services_screen.dart` - Catálogo de serviços com estados de carregamento, erro e lista vazia.
- `lib/screens/service_details_screen.dart` - Detalhes do serviço e escolha do profissional.
- `lib/screens/schedule_screen.dart` - Calendário, grade de horários e validação de disponibilidade.
- `lib/screens/booking_confirmed_screen.dart` - Comprovante com serviço, profissional, data, faixa de horário e valor.
- `lib/screens/appointments_screen.dart` - Lista de agendamentos ativos e histórico.
- `lib/screens/login_screen.dart` - Login e cadastro com e-mail e senha.
- `lib/screens/auth_gate.dart` - Controle de acesso por sessão.
- `lib/screens/root_shell.dart` - Barra de navegação inferior Início/Agendamentos.
- `lib/widgets/logout_button.dart` - Encerramento de sessão e retorno ao login.

## Funcionalidades desenvolvidas

- Cadastro e login via Supabase Auth, com sessão persistida e botão Sair.
- Catálogo de serviços e barbeiros carregado do banco, com fallback local quando não há credenciais.
- Seleção de profissional com especialidade.
- Agenda por barbeiro, com bloqueio de horários ocupados e expirados.
- Registro de agendamento com `user_id` do usuário autenticado.
- Consulta dos agendamentos do próprio usuário na aba Agendamentos.
- Formatação de data e moeda em pt_BR e mensagens de erro em português.

## Integração com o banco

- `supabase/schema.sql` cria `services`, `barbers` e `appointments`.
- `appointments.user_id` referencia `auth.users(id)` com `on delete cascade`.
- Trigger `prepare_appointment()` calcula `end_time` e `total_price` e bloqueia conflitos de horário para o mesmo barbeiro.
- Row Level Security habilitado nas três tabelas: catálogo público para leitura; agendamentos apenas para o dono (`auth.uid() = user_id`).
- Permissões concedidas apenas ao necessário; `service_role key` não é usada no app.
- Credenciais lidas de `.env`; a publishable key não está incluída neste relatório.

## Navegação

- `lib/app.dart` registra `AppNavigator.rootKey` e define `AuthGate` como raiz.
- `AuthGate` redirect para Login sem sessão e invalida os agendamentos ao trocar de usuário.
- `AppNavigator` força o primeiro route após autenticar.
- `LogoutButton` chama `signOut()` e retorna ao Login.

## Adequação às telas descritas no README

Referência: item "Telas e Fluxo do Aplicativo" do `README.md`. A comparação é de fluxo, conteúdo e estados, não de medidas visuais, pois não há wireframe original no repositório.

| Etapa do README | Implementação | Situação |
| --- | --- | --- |
| 01 - Início | `home_screen.dart` + `root_shell.dart` | Conforme: hero, atalho e destaques; barra Início/Agendamentos |
| 02 - Nossos Serviços | `services_screen.dart` | Conforme: catálogo com fotos, descrição, duração e valor |
| 03 - Detalhes do Serviço | `service_details_screen.dart` | Conforme: resumo e escolha do profissional; badge alinhado para `03 | SERVIÇO` |
| 04 - Escolha de Horário | `schedule_screen.dart` | Conforme: calendário e grade em tempo real por barbeiro |
| 05 - Agendamento Confirmado | `booking_confirmed_screen.dart` | Conforme: resumo completo do agendamento |

A tela de Login/Cadastro é adicional ao fluxo original e necessária para o Supabase Auth.

## Evidências

- `flutter test`: 13 testes passaram.
- `flutter analyze --no-fatal-infos`: exit 0, sem erros; apenas avisos `deprecated_member_use` pré-existentes.
- Supabase Auth health: 200.
- REST: `services` e `barbers` retornaram 200; `appointments` sem autenticação retornou 401/42501, confirmando RLS.
- Configuração final do Auth: `disable_signup=False`, `mailer_autoconfirm=True`, `external.email=True`.
- Cadastro com senha curta retornou 422/`weak_password`; e-mail já existente retornou 400/`email_address_invalid`.
- Login com conta não confirmada retornou 400/`email_not_confirmed`; após ajuste no Supabase, o acesso foi confirmado pelo usuário.
- App web servido em `http://127.0.0.1:8080` com HTTP 200.

## Pendências

- Wireframes visuais originais não disponíveis no repositório; a validação usou o README.
- Prints e evidências visuais não incluídos, conforme opção de relatório somente em texto.
- Android Studio/emulador não instalados; teste em dispositivo Android pendente.
- Recuperação de senha e cancelamento de agendamento pelo app não implementados.
