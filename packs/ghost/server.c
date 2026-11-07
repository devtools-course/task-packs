#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "lihtar.h"

#define PORT 8870

static int write_all(int fd, const char *buf, size_t len) {
    while (len > 0) {
        const ssize_t n = write(fd, buf, len);
        if (n == -1) {
            return -1;
        }
        buf += n;
        len -= n;
    }

    return 0;
}

int main(void) {
    sleep(3);

    signal(SIGPIPE, SIG_IGN);

    const int sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (sock_fd == -1) {
        perror("Failed to create socket");
        return 1;
    }

    const int on = 1;
    setsockopt(sock_fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);

    if (bind(sock_fd, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        perror("Cannot bind the port");
        return 1;
    }

    if (listen(sock_fd, 16) == -1) {
        perror("Failed to start listening");
        return 1;
    }

    fprintf(stderr, "Listening on http://localhost:%d\n", PORT);

    while (1) {
        const int cfd = accept(sock_fd, NULL, NULL);
        if (cfd == -1) {
            perror("Cannot accept connection");
            continue;
        }

        char req[4096];
        read(cfd, req, sizeof(req));

        const char *body = light();
        const size_t blen = strlen(body);

        char hdr[256];
        int hlen = snprintf(hdr, sizeof(hdr),
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/plain; charset=utf-8\r\n"
            "Content-Length: %zu\r\n"
            "Connection: close\r\n\r\n", blen);

        if (write_all(cfd, hdr, hlen) == 0) {
            write_all(cfd, body, blen);
        }

        close(cfd);
    }
}
