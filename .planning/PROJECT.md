# Teto Locadora — Plataforma de Agentes de IA

## What This Is

Plataforma interna de agentes de IA para a Teto Locadora, uma empresa de aluguel de equipamentos para obras. A plataforma permite criar e configurar agentes de IA (SDR, Vendedor, Suporte) que atuam de forma autônoma em canais como WhatsApp e Instagram, qualificando leads, gerenciando o CRM e distribuindo oportunidades para vendedores humanos.

## Core Value

O agente SDR qualifica leads automaticamente via WhatsApp, gerencia o CRM de forma autônoma e distribui leads prontos para vendedores na fila rotativa — sem intervenção manual.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Agentes de IA configuráveis (prompt, personalidade, regras) usando OpenAI GPT
- [ ] Chat multi-canal (WhatsApp + Instagram DMs)
- [ ] Multi-inbox — múltiplos WhatsApp conectados, cada um com seu chat
- [ ] Integração WhatsApp via API Oficial (Meta) e Evolution API
- [ ] CRM interno com pipelines múltiplos
- [ ] Agente com acesso completo ao CRM (criar, editar, excluir, mover cards entre estágios)
- [ ] Qualificação de leads por IA + regras mínimas obrigatórias configuráveis
- [ ] Distribuição rotativa de leads qualificados para vendedores
- [ ] Multi-usuário: acesso gerencial (tudo) e acesso vendedor (só seus leads)
- [ ] Dashboard de monitoramento (agentes ativos, conversas abertas, em atendimento)
- [ ] Dashboard analítico da plataforma
- [ ] API e webhooks para integrações externas
- [ ] Integração Instagram DMs

### Out of Scope

- Instagram comentários — foco em DMs apenas, comentários podem ser adicionados depois
- Multi-tenant/SaaS — plataforma é interna para Teto Locadora
- App mobile nativo — web-first
- Integração com CRM externo (Hubspot, Pipedrive) — CRM é interno, mas API permite integração futura

## Context

- Teto Locadora é uma locadora de equipamentos para obras (construção civil)
- Equipe de 10-50 usuários simultâneos (vendedores + gestores)
- Fluxo principal: Lead chega no WhatsApp → Agente SDR conversa e qualifica → Quando pronto, distribui rotativamente para o próximo vendedor na fila → Vendedor fecha negócio
- O agente SDR precisa entender necessidades de aluguel de equipamentos (tipos, prazos, orçamentos)
- CRM interno com API para permitir integrações futuras sem depender de terceiros

## Constraints

- **IA Model**: OpenAI GPT (GPT-4o / GPT-4o-mini) — modelo escolhido para os agentes
- **Scale**: 10-50 usuários simultâneos — não precisa de hiper-escalabilidade mas deve ser robusto
- **Channels**: WhatsApp (API Oficial + Evolution API) e Instagram DMs — são os canais prioritários
- **Internal use**: Plataforma interna — sem necessidade de billing, onboarding self-service, etc.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Plataforma interna (não SaaS) | Foco na Teto Locadora, sem complexidade multi-tenant | — Pending |
| CRM interno com API | Controle total sobre o CRM, sem dependência de terceiros | — Pending |
| WhatsApp dual (Oficial + Evolution) | Flexibilidade — API Oficial para escala, Evolution para custo zero | — Pending |
| OpenAI GPT como modelo de IA | Modelo escolhido pelo cliente | — Pending |
| Agentes configuráveis | Usuário define prompt, personalidade e regras de cada agente | — Pending |

---
*Last updated: 2026-03-11 after initialization*
