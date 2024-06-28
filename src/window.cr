module Text::Viewer
  @[Gtk::UiTemplate(
    resource: "/com/example/TextViewer/text-viewer-window.ui",
    children: {
      "header_bar",
      "main_text_view",
      "open_button",
      "cursor_pos",
    }
  )]
  class Window < Adw::ApplicationWindow
    include Gtk::WidgetTemplate

    @header_bar = Adw::HeaderBar
    @main_text_view : Gtk::TextView
    @open_button : Gtk::Button
    @cursor_pos : Gtk::Label

    @settings : Gio::Settings

    def initialize
      super()

      @settings = Gio::Settings.new("com.example.TextViewer")

      @header_bar = Adw::HeaderBar.cast(template_child("header_bar"))
      @main_text_view = Gtk::TextView.cast(template_child("main_text_view"))
      @open_button = Gtk::Button.cast(template_child("open_button"))
      @cursor_pos = Gtk::Label.cast(template_child("cursor_pos"))

      open_action = Gio::SimpleAction.new("open", nil)
      open_action.activate_signal.connect do
        self.open_file_dialog
      end
      self.add_action open_action

      save_action = Gio::SimpleAction.new("save-as", nil)
      save_action.activate_signal.connect do
        self.save_file_dialog
      end
      self.add_action save_action

      @main_text_view.buffer.notify_signal["cursor-position"].connect do
        buffer = @main_text_view.buffer
        cursor_position = buffer.cursor_position
        iter = buffer.iter_at_offset(cursor_position)
        @cursor_pos.label = "Ln #{iter.line}, Col #{iter.line_offset}"
      end

      @settings.bind("window-width", self, "default-width", Gio::SettingsBindFlags::Default)
      @settings.bind("window-height", self, "default-height", Gio::SettingsBindFlags::Default)
      @settings.bind("window-maximized", self, "maximized", Gio::SettingsBindFlags::Default)
    end

    private def save_file_dialog
      filechooser = Gtk::FileChooserNative.new("Save File As", nil, Gtk::FileChooserAction::Save, "_Save", "_Cancel")
      filechooser.transient_for = self
      filechooser.response_signal.connect do |response|
        if Gtk::ResponseType.from_value(response) == Gtk::ResponseType::Accept
          self.save_file(filechooser.file)
        end
      end

      filechooser.show
    end

    private def save_file(file : Gio::File?)
      return if file.nil?

      file_path = file.not_nil!.path.not_nil!
      File.open(file_path, "w") do |file_io|
        buffer = @main_text_view.buffer

        # Retrieve the iterator at the start of the buffer
        start_iter = buffer.start_iter

        # Retrieve the iterator at the end of the buffer
        end_iter = buffer.end_iter

        # Retrieve all the visible text between the two bounds
        text = buffer.text(start_iter, end_iter, false)
        return if text.size == 0

        file_io.print(text)
      end
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
