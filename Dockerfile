FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 as prepare

# gather only artifacts necessary for nuget restore, retaining directory structure
COPY . C:/temp
RUN Invoke-Expression 'robocopy C:/temp C:/nuget /s /ndl /njh /njs nuget.config *.sln *.csproj packages.config'

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 AS build

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ARG CONFIGURATION=Release

WORKDIR C:\\workspace

# restore packages
COPY --from=prepare C:/nuget .
RUN msbuild -t:Restore -p:RestorePackagesConfig=true -m -v:m -noLogo

# build and publish website project
COPY src/ ./src/
RUN msbuild -t:Build -p:Configuration=$($env:CONFIGURATION) -p:PublishUrl='C:\\out\\Website' -p:DeployOnBuild=True -p:DeployDefaultTarget=WebPublish -p:WebPublishMethod=FileSystem -p:CollectWebConfigsToTransform=False -p:TransformWebConfigEnabled=False -p:AutoParameterizationWebConfigConnectionStrings=False -m -v:m -noLogo ./src/Project/code/Website/Website.csproj

# copy solution files ignored by msbuild publish
RUN Copy-Item -Path '.\\src\\Project\\code\\Website\\*.*.config' -Destination 'C:\\out\\Website'

FROM build as production

WORKDIR C:\\workspace

# copy serialized items
RUN Copy-Item -Path '.\\src\\Foundation\\serialization' -Destination 'C:\\out\\serialization\\Foundation' -Recurse -Force; \
    Copy-Item -Path '.\\src\\Feature\\serialization' -Destination 'C:\\out\\serialization\\Feature' -Recurse -Force; \
    Copy-Item -Path '.\\src\\Project\\serialization' -Destination 'C:\\out\\serialization\\Project' -Recurse -Force;
