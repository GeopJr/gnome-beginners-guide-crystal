module Text::Viewer
  @[Gtk::UiTemplate(
    resource: "/com/example/TextViewer/text-viewer-window.ui",
    children: {
      "header_bar",
      "main_text_view",
    }
  )]
  class Window < Adw::ApplicationWindow
    include Gtk::WidgetTemplate

    @header_bar = Adw::HeaderBar
    @main_text_view : Gtk::TextView

    def initialize
      super()

      @header_bar = Adw::HeaderBar.cast(template_child("header_bar"))
      @main_text_view = Gtk::TextView.cast(template_child("main_text_view"))
    end
  end
end
