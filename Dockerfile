FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 as build

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

ARG CONFIGURATION=Release

WORKDIR C:\\workspace

# restore packages
RUN New-Item -Path 'C:\\Program Files\\dotnet\\sdk\\NuGetFallbackFolder' -ItemType Directory | Out-Null;
COPY nuget.config .
COPY *.sln .
COPY ./src/Foundation/code/Foundation.csproj ./src/Foundation/code/Foundation.csproj
COPY ./src/Feature/code/Feature.csproj ./src/Feature/code/Feature.csproj
COPY ./src/Project/code/Website/packages.config ./src/Project/code/Website/packages.config
COPY ./src/Project/code/Website/Website.csproj ./src/Project/code/Website/Website.csproj
RUN nuget restore

# build solution
COPY . .
RUN msbuild /m /v:m /t:Build /p:Configuration=$($env:CONFIGURATION) /p:DeployOnBuild=True /p:DeployDefaultTarget=WebPublish /p:WebPublishMethod=FileSystem /p:PublishUrl='C:\\out\\Website' /p:TransformWebConfigEnabled=False /p:AutoParameterizationWebConfigConnectionStrings=False

# copy solution files ignored by msbuild publish
RUN Copy-Item -Path '.\\src\\Project\\code\\Website\\*.*.config' -Destination 'C:\\out\\Website'

FROM build as production

WORKDIR C:\\workspace

# copy serialized items
RUN Copy-Item -Path '.\\src\\Foundation\\serialization' -Destination 'C:\\out\\serialization\\Foundation' -Recurse -Force; \
    Copy-Item -Path '.\\src\\Feature\\serialization' -Destination 'C:\\out\\serialization\\Feature' -Recurse -Force; \
    Copy-Item -Path '.\\src\\Project\\serialization' -Destination 'C:\\out\\serialization\\Project' -Recurse -Force;
