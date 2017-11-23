FROM alpine:latest

ENV PANDOC_VERSION 2.0.3
ENV PANDOC_ARCHIVE pandoc-$PANDOC_VERSION
ENV PANDOC_URL https://github.com/jgm/pandoc/releases/download/$PANDOC_VERSION/

ENV CROSSREF_VERSION v0.3.0.0-beta3
ENV CROSSREF_ARCHIVE linux-ghc8-pandoc-2-0.tar.gz
ENV CROSSREF_URL https://github.com/lierdakil/pandoc-crossref/releases/download/$CROSSREF_VERSION

RUN apk --no-cache add -U make nodejs-npm curl openssl gcc libc-dev && \
    mkdir -p /workspace

WORKDIR /workspace

RUN wget --no-check-certificate $PANDOC_URL/$PANDOC_ARCHIVE-linux.tar.gz && \
    tar zxf $PANDOC_ARCHIVE-linux.tar.gz && cp $PANDOC_ARCHIVE/bin/* /usr/local/bin/ && \

    wget --no-check-certificate $CROSSREF_URL/$CROSSREF_ARCHIVE && \
    tar zxf $CROSSREF_ARCHIVE && \
    mv pandoc-crossref /usr/local/bin/

RUN apk --no-cache add -U python3 py3-pillow libxml2-dev libxslt-dev python3-dev

RUN npm install -g phantomjs-prebuilt wavedrom-cli \
      fs-extra yargs onml bit-field

RUN mkdir -p /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
      wget -c https://github.com/zr-tex8r/BXptool/archive/v0.4.zip && \
      unzip v0.4.zip && \
      cp BXptool-0.4/bx*.sty BXptool-0.4/bx*.def /usr/share/texlive/texmf-dist/tex/latex/BXptool/ && \
    mkdir -p /usr/local/share/fonts && \
    wget -c https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip && \
      unzip 1.050R-it.zip && cp source-code-pro-2.030R-ro-1.050R-it/TTF/SourceCodePro-*.ttf /usr/local/share/fonts/ && \
    wget -c https://github.com/adobe-fonts/source-sans-pro/archive/2.020R-ro/1.075R-it.zip && \
      unzip 1.075R-it.zip && cp source-sans-pro-2.020R-ro-1.075R-it/TTF/SourceSansPro-*.ttf /usr/local/share/fonts/

# dependencies for texlive
RUN apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/main \
    poppler harfbuzz-icu py3-libxml2 && \
      pip3 install \
      pantable csv2table \
      six pandoc-imagine \
      svgutils && \
      pip3 install pyyaml
# zziplib (found in edge/community repository) is a dependency to texlive-luatex
RUN apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/community \
    zziplib && \

    apk --no-cache add -U --repository http://dl-3.alpinelinux.org/alpine/edge/testing \
    texlive-xetex && \

    ln -s /usr/bin/mktexlsr /usr/bin/mktexlsr.pl && \
    mktexlsr

RUN apk del *-dev *-doc
