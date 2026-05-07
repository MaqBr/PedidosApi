# ============================================================
#  PedidosApi — Dockerfile multi-stage
#  Build: mcr.microsoft.com/dotnet/sdk:10.0
#  Runtime: mcr.microsoft.com/dotnet/aspnet:10.0
# ============================================================

# ── Estágio 1: Build ─────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restaura dependências antes de copiar o restante (otimiza cache)
COPY PedidosApi.csproj ./
RUN dotnet restore PedidosApi.csproj

# Copia o código-fonte (excluindo o que está no .dockerignore)
COPY . .

# Publica a aplicação em modo Release
RUN dotnet publish PedidosApi.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

# ── Estágio 2: Runtime ───────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Usuário não-root por boas práticas de segurança
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

COPY --from=build /app/publish .

# ASP.NET Core 8+ usa porta 8080 por padrão (não-root friendly)
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "PedidosApi.dll"]
