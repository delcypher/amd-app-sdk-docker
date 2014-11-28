FROM ubuntu:14.04
MAINTAINER Dan Liew <daniel.liew@imperial.ac.uk>

RUN apt-get update && apt-get -y install curl
RUN apt-get -y install gcc g++ gdb
RUN apt-get -y --no-install-recommends install cmake mercurial git make subversion
RUN apt-get -y install python python-dev python-pip vim

WORKDIR /root
# Get AMD APP SDK from the AMD website. This is a hack that will probably fail due to the nonce
RUN curl 'http://developer.amd.com/amd-license-agreement-appsdk/' -H 'Cookie: __utmt=1; c_sccva=1417131451000%2COS; __utma=34774836.280040427.1417131451.1417131451.1417131451.1; __utmb=34774836.4.10.1417131451; __utmc=34774836; __utmz=34774836.1417131451.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); s_cc=true; com.silverpop.iMAWebCookie=6ae8b15d-bb11-823b-0c95-6134a25140dc; com.silverpop.iMA.page_visit=-540389405,1770512312,; fsr.s=%7B%22v2%22%3A-2%2C%22v1%22%3A-2%2C%22rid%22%3A%22d1159f3-80451668-dfed-f214-275b6%22%2C%22ru%22%3A%22https%3A%2F%2Fwww.google.co.uk%2F%22%2C%22r%22%3A%22www.google.co.uk%22%2C%22st%22%3A%22%22%2C%22to%22%3A5%2C%22c%22%3A%22http%3A%2F%2Fdeveloper.amd.com%2Famd-license-agreement-appsdk%2F%22%2C%22pv%22%3A4%2C%22lc%22%3A%7B%22d0%22%3A%7B%22v%22%3A4%2C%22s%22%3Atrue%7D%7D%2C%22cd%22%3A0%2C%22f%22%3A1417131459930%2C%22sd%22%3A0%7D; com.silverpop.iMA.session=52bc1012-69d3-2727-8a46-44c5d7bb6e41; s_vi=[CS]v1|2A3BDA7F851D030D-40000137A02CAA86[CE]; s_fid=21459A64B5FB1A3D-3773C664AC84F735; s_sq=amdvother21%252Camdvdev%252Camdvbusiness%252Camdvglobal%3D%2526pid%253D%25252Fdeveloper.amd.com%25252Famd-license-agreement-appsdk%25252F%2526pidt%253D1%2526oid%253Dfunctiononclick%252528event%252529%25257B%252524%252528%252527form%252523download%252527%252529.submit%252528%252529%25253B%25257D%2526oidt%253D2%2526ot%253DA' -H 'Origin: http://developer.amd.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-GB,en-US;q=0.8,en;q=0.6' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.65 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://developer.amd.com/amd-license-agreement-appsdk/' -H 'Connection: keep-alive' -H 'DNT: 1' --data 'amd_developer_central_nonce=15e1ab6859&_wp_http_referer=%2Famd-license-agreement-appsdk%2F&f=QU1ELUFQUC1TREstbGludXgtdjIuOS0xLjU5OS4zODEtR0EteDY0LnRhci5iejI%3D' --compressed -o 'AMD-APP-SDK-linux-v2.9-1.599.381-GA-x64.tar.bz2'
RUN tar -xvf AMD-APP-SDK-linux-*.tar.bz2 && rm AMD-APP-SDK-linux-*.tar.bz2

# Finally we can install it
RUN ./AMD-APP-SDK-*.sh -- --acceptEULA 'yes' -s

# Remove installation files
RUN rm AMD-APP-SDK-*.sh && rm -rf AMDAPPSDK-*

# Remove the samples. Keep the OpenCL ones
RUN rm -rf /opt/AMDAPPSDK-*/samples/{aparapi,bolt,opencv}

# Put the includes and library where they are expected to be
RUN ln -s /opt/AMDAPPSDK-2.9-1/include/CL /usr/include/ && ln -s /opt/AMDAPPSDK-2.9-1/lib/x86_64/libOpenCL.so.1 /usr/lib/OpenCL.so

# Provide easy access to root if needed
RUN echo "root:root" | chpasswd

# Add a non root user
RUN useradd -m aasdk
USER aasdk
WORKDIR /home/aasdk
