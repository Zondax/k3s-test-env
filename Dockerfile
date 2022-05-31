FROM ubuntu:20.04

COPY ./scripts/* ./

CMD ["/bin/bash"]