all: clean
	hugo --destination docs
clean:
	rm -r docs/*
