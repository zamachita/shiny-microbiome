# R version: 4, 4.1, 4.0
ARG VARIANT="4.1.2"
FROM rocker/r-ver:${VARIANT}

# Use the [Option] comment to specify true/false arguments that should appear in VS Code UX
#
# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && usermod -a -G staff ${USERNAME} \
    && apt-get -y install \
        python3-pip \
        libgit2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libxt-dev \
    && python3 -m pip --no-cache-dir install radian \
	&& install2.r --error --skipinstalled --ncpus -1 \
        devtools \
        languageserver \
        httpgd

# COIN is for statistical package (masslin2), CAIRO are for graphic (use by EnhancedVolcano).

# Auto install mscorefonts
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

RUN apt-get -y install --no-install-recommends libcurl4-openssl-dev libssl-dev libxml2-dev libcoin-dev libnode-dev libglpk-dev libgsl-dev \
    && apt-get -y install --no-install-recommends libcairo2-dev libproj-dev \
    && apt-get -y install --no-install-recommends ttf-mscorefonts-installer \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts && rm -rf /tmp/downloaded_packages    

# Install font (some journal want arial)
RUN fc-cache -f

RUN export TAG=$(git ls-remote --tags --refs --sort='version:refname' https://github.com/ManuelHentschel/vscDebugger v\* | tail -n 1 | cut --delimiter='/' --fields=3) \
    && Rscript -e "remotes::install_git('https://github.com/ManuelHentschel/vscDebugger.git', ref = '"${TAG}"', dependencies = FALSE)"

# R Session watcher settings.
# See more details: https://github.com/REditorSupport/vscode-R/wiki/R-Session-watcher
RUN echo 'source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))' >> ${R_HOME}/etc/Rprofile.site

RUN install2.r --error --skipinstalled --ncpus -1 renv

# Make folder for mount
RUN mkdir -p /home/${USERNAME}/.cache/R/renv/binary \
  && mkdir -p /home/${USERNAME}/.cache/R/renv/cache \
  && mkdir -p /home/${USERNAME}/.cache/R/renv/source \
  && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.cache
