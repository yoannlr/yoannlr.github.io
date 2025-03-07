all: clean
	hugo --destination docs
clean:
	rm -r docs/* || true
	rm -r public || true
stats:
	ls content | xargs -I file basename file .md | tr -c '[:alnum:]-_.\\\n' 'x' | xargs -I slug sh -c 'echo -n "slug: " ; curl -L "https://abacus.jasoncameron.dev/get/yoannlr.github.io/slug"; echo'
