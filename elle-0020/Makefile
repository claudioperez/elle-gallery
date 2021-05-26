
all:
	for i in src/*.ipynb; do TMP=$$(basename $$i); make $${TMP/ipynb/md}; done

%.md: src/%.ipynb
	pandoc --defaults ipynb $< -o $@	
