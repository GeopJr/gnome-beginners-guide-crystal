module Text::Viewer
  @[Gtk::UiTemplate(
    resource: "/com/example/TextViewer/text-viewer-window.ui",
    children: {
      "header_bar",
      "main_text_view",
      "open_button",
    }
  )]
  class Window < Adw::ApplicationWindow
    include Gtk::WidgetTemplate

    @header_bar = Adw::HeaderBar
    @main_text_view : Gtk::TextView
    @open_button : Gtk::Button

    def initialize
      super()

      @header_bar = Adw::HeaderBar.cast(template_child("header_bar"))
      @main_text_view = Gtk::TextView.cast(template_child("main_text_view"))
      @open_button = Gtk::Button.cast(template_child("open_button"))

      open_action = Gio::SimpleAction.new("open", nil)
      open_action.activate_signal.connect do
        self.open_file_dialog
      end
      self.add_action open_action
    end

    private def open_file_dialog
      filechooser = Gtk::FileChooserNative.new("Open File", nil, Gtk::FileChooserAction::Open, "_Open", "_Cancel")
      filechooser.transient_for = self
      filechooser.response_signal.connect do |response|
        # If the user selected a file...
        if Gtk::ResponseType.from_value(response) == Gtk::ResponseType::Accept
          # ... retrieve the location from the dialog and open it
          self.open_file(filechooser.file)
        end
      end

      filechooser.show
    end

    private def open_file(file : Gio::File?)
      return if file.nil?

      file_path = file.not_nil!.path.not_nil!
      File.open(file_path) do |file_io|
        self.title = File.basename(file_path, File.extname(file_path))

        # Retrieve the `Gtk::TextBuffer` instance that stores the
        # text displayed by the `Gtk::TextView` widget
        buffer = @main_text_view.buffer

        # Set the text using the contents of the file
        buffer.text = file_io.gets_to_end
        # Reposition the cursor so it's at the start of the text
        buffer.place_cursor(buffer.start_iter)
      end
    end
  end
end
