.PHONY: all install uninstall build mo desktop
PREFIX ?= /usr

all: desktop bindings build

run:
	crystal run src/text-viewer.cr

build:
	shards build --release --no-debug

schema:
	install -D -m 0644 data/com.example.TextViewer.gschema.xml $(PREFIX)/share/glib-2.0/schemas/com.example.TextViewer.gschema.xml
	gtk-update-icon-cache $(PREFIX)/share/icons/hicolor
	glib-compile-schemas $(PREFIX)/share/glib-2.0/schemas/

install: schema
	install -D -m 0755 bin/text-viewer $(PREFIX)/bin/text-viewer
	install -D -m 0644 data/com.example.TextViewer.desktop $(PREFIX)/share/applications/com.example.TextViewer.desktop
	install -D -m 0644 data/icons/hicolor/scalable/apps/com.example.TextViewer.svg $(PREFIX)/share/icons/hicolor/scalable/apps/com.example.TextViewer.svg
	install -D -m 0644 data/icons/hicolor/symbolic/apps/com.example.TextViewer-symbolic.svg $(PREFIX)/share/icons/hicolor/symbolic/apps/com.example.TextViewer-symbolic.svg

uninstall:
	rm -f $(PREFIX)/bin/text-viewer
	rm -f $(PREFIX)/share/glib-2.0/schemas/com.example.TextViewer.gschema.xml
	rm -f $(PREFIX)/share/applications/com.example.TextViewer.desktop
	rm -f $(PREFIX)/share/icons/hicolor/scalable/apps/com.example.TextViewer.svg
	rm -f $(PREFIX)/share/icons/hicolor/symbolic/apps/com.example.TextViewer-symbolic.svg
	gtk-update-icon-cache $(PREFIX)/share/icons/hicolor

validate-appstream:
	appstreamcli validate ./data/com.example.TextViewer.metainfo.xml
