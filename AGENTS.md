# Instruções para assistentes que trabalharem neste repositório

1. Leia `PROJECT_CONTEXT.md`, `README.md` e `APP_STORE.md` antes de propor alterações. `PROJECT_CONTEXT.md` registra objetivo, decisões, verificações e próximos passos.
2. O projeto ativo é Flutter na raiz e `ios/Runner.xcworkspace`. `Desvicio.xcodeproj` e `Desvicio/` são a versão SwiftUI anterior, mantida como referência.
3. No iOS, preservar a ponte Flutter–Swift, as extensões `DesvicioMonitor` e `DesvicioShield`, os identificadores `com.desvicio.app` / `com.desvicio.app.monitor` / `com.desvicio.app.shield` e o App Group `group.com.desvicio.app`, salvo se houver uma migração planejada.
4. Distinguir código compilado de recurso validado em aparelho físico. O bloqueio de apps ainda precisa de teste real; Android ainda não mede nem bloqueia apps.
5. Não introduzir login, backend, anúncios, compras ou assinatura como se já fossem decisões de produto. Se adicionar contas no futuro, contemplar login equivalente quando exigido e exclusão de conta dentro do app.
6. Após mudanças relevantes, executar as verificações aplicáveis e atualizar `PROJECT_CONTEXT.md` e `APP_STORE.md` com resultados e pendências. Não declarar prontidão para publicação sem cumprir os requisitos descritos ali.
