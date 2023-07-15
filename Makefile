install:
	mkdir -p /usr/share/sddm/themes/Oction
	cp -r * /usr/share/sddm/themes/Oction
	mkdir -p /etc/sddm.conf.d/
	echo -e "[Theme]\nCurrent=Oction\n" > /etc/sddm.conf.d/oction_theme.conf

uninstall:
	rm -r /usr/share/sddm/themes/Oction
	rm /etc/sddm.conf.d/oction_theme.conf

.PHONY: install
