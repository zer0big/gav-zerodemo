# 런타임 전용 기본 이미지를 지정하여 단계를 시작하고 참조를 위해 base로 명명
FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base

# 이미지에 작업디렉토리 /app  생성
WORKDIR /app

# 80, 443 포트 노출
EXPOSE 80
EXPOSE 443

# 빌드/개시용 이미지를 사용하여 새로운 단계를 시작하고 참조를 위해 build로 명명
FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build

# 이미지에 작업디렉토리 /src 생성
WORKDIR /src

# 패키지를 나중에 Restore 할 수 있도록 .csproj 프로젝트 파일 복사
COPY ["azure-virtual-zerodemo.csproj", ""]

# 프로젝트(및 기타 프로젝트 종속성) restore
RUN dotnet restore "./azure-virtual-zerodemo.csproj"

# 솔루션의 모든 디렉터리 트리를 이미지의 /src 디렉터리로 복사
COPY . .

# 현재 디렉토리를 /src/로 변경
WORKDIR "/src/."

# 프로젝트(및 기타 프로젝트 종속성) 빌드 및 이미지의 /app/build 디렉터리에 출력 
RUN dotnet build "azure-virtual-zerodemo.csproj" -c Release -o /app/build

# build로부터 이어지는 새 단계 시작. 참조를 위해 publish로 명명
FROM build AS publish

# 프로젝트(및 종속성)를 게시하고 이미지의 /app/publish 디렉토리에 출력
RUN dotnet publish "azure-virtual-zerodemo.csproj" -c Release -o /app/publish

# base로부터 이어지는 새 단계를 시작하고 이를 final로 명명
FROM base AS final

# 현재 디렉토리를 /app으로 변경
WORKDIR /app

# publish 단계에서 현재 디렉터리로 /app/publish 디렉토리를 복사

COPY --from=publish /app/publish .

# 컨테이너가 시작될 때 실행할 명령 정의
ENTRYPOINT ["dotnet", "azure-virtual-zerodemo.dll"]
