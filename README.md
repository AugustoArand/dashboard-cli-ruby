# 🚀 Dashboard CLI Ruby

Um dashboard interativo de linha de comando desenvolvido em Ruby, integrando múltiplas APIs para fornecer informações úteis de forma elegante e intuitiva.

![Ruby](https://img.shields.io/badge/Ruby-%3E%3D%202.7-red)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Funcionalidades

- **👤 GitHub** - Busca de perfis de usuários e repositórios
- **🌤️ Clima** - Previsão do tempo em tempo real via OpenWeatherMap
- **📍 CEP** - Consulta de endereços brasileiros via ViaCEP
- **💰 Crypto** - Cotações de criptomoedas via CoinGecko

## 🎯 Características

- ✅ Menu interativo com navegação por setas (↑/↓)
- ✅ Spinners de loading animados
- ✅ Cores e formatação elegante no terminal
- ✅ 4 APIs integradas
- ✅ Código modular e bem documentado

## 📁 Estrutura do Projeto

```
dashboard-cli-ruby/
├── main.rb                          # Ponto de entrada
├── Gemfile                          # Dependências
├── .env.example                     # Exemplo de configuração
├── README.md                        # Documentação
└── lib/
    └── dashboard/
        ├── dashboard.rb             # Orquestrador principal
        ├── menu.rb                  # Menu interativo
        ├── api/
        │   ├── github.rb            # Cliente GitHub API
        │   ├── weather.rb           # Cliente OpenWeatherMap
        │   ├── viacep.rb            # Cliente ViaCEP
        │   └── coingecko.rb         # Cliente CoinGecko
        └── helpers/
            ├── display.rb           # Helpers de formatação
            └── spinner.rb           # Helpers de loading
```

## 🛠️ Instalação

### Pré-requisitos

- Ruby >= 2.7
- Bundler

### Passos

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/dashboard-cli-ruby.git
cd dashboard-cli-ruby
```

2. **Instale as dependências**
```bash
bundle install
```

3. **Configure as variáveis de ambiente**
```bash
cp .env.example .env
```

4. **Edite o arquivo `.env`** com suas API keys:
```env
# Opcional - aumenta rate limit do GitHub
GITHUB_TOKEN=seu_token_aqui

# Obrigatório para consultas de clima
OPENWEATHERMAP_API_KEY=sua_chave_aqui
```

## 🚀 Uso

Execute o dashboard com:

```bash
ruby main.rb
```

### Navegação

- Use **↑** e **↓** para navegar entre as opções
- Pressione **Enter** para selecionar
- Siga as instruções na tela para cada funcionalidade

## 📦 Dependências

| Gem | Descrição |
|-----|-----------|
| `httparty` | Cliente HTTP para requisições às APIs |
| `tty-prompt` | Menu interativo com navegação por setas |
| `tty-spinner` | Spinners de loading animados |
| `colorize` | Cores no terminal |
| `dotenv` | Gerenciamento de variáveis de ambiente |

## 🔑 APIs Utilizadas

### GitHub API
- **Documentação**: https://docs.github.com/en/rest
- **Autenticação**: Token pessoal (opcional, mas recomendado)
- **Limite**: 60 req/hora (sem token) ou 5000 req/hora (com token)

### OpenWeatherMap
- **Documentação**: https://openweathermap.org/api
- **Autenticação**: API Key (obrigatório)
- **Cadastro gratuito**: https://openweathermap.org/appid

### ViaCEP
- **Documentação**: https://viacep.com.br/
- **Autenticação**: Não requer
- **Uso**: Gratuito e ilimitado

### CoinGecko
- **Documentação**: https://www.coingecko.com/en/api
- **Autenticação**: Não requer para uso básico
- **Limite**: 10-50 req/minuto (plano gratuito)

## 🎨 Capturas de Tela

### Menu Principal
```
╔════════════════════════════════════════════════════════════════════════════╗
║                    🚀 Dashboard Interativo em Ruby 🚀                      ║
╚════════════════════════════════════════════════════════════════════════════╝

Escolha uma opção:
❯ 👤 GitHub - Buscar perfil de usuário
  🌤️  Clima - Consultar previsão do tempo
  📍 CEP - Buscar endereço por CEP
  💰 Crypto - Cotações de criptomoedas
  ℹ️  Sobre - Informações do dashboard
  🚪 Sair
```

### Exemplo: Consulta GitHub
```
═══════════════════════════════════════════════════════════════════════════════
                               👤 Perfil GitHub                                
═══════════════════════════════════════════════════════════════════════════════

  Login: octocat
  Nome: The Octocat
  Bio: GitHub's mascot
  Repositórios Públicos: 8
  Seguidores: 10000
  Seguindo: 9
```

## 🧪 Testes

Execute os testes com:

```bash
bundle exec rspec
```

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 👨‍💻 Autor

Desenvolvido para praticar integração de APIs em Ruby.

---

⭐ Se este projeto foi útil, considere dar uma estrela!
