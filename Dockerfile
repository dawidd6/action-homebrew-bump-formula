FROM homebrew/brew

COPY *.sh /

ENTRYPOINT ["/main.sh"]
