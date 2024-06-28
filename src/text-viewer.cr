require "libadwaita"
require "./window"

module Text::Viewer
  VERSION = "1.0.0"
  Gio.register_resource("#{__DIR__}/text-viewer.gresource.xml", "#{__DIR__}")

  class App < Adw::Application
    def initialize
      super(application_id: "com.example.TextViewer", flags: Gio::ApplicationFlags::DefaultFlags)

      about_action = Gio::SimpleAction.new("about", nil)
      about_action.activate_signal.connect do
        on_about_action
      end

      preferences_action = Gio::SimpleAction.new("preferences", nil)
      preferences_action.activate_signal.connect do
        on_preferences_action
      end

      quit_action = Gio::SimpleAction.new("quit", nil)
      quit_action.activate_signal.connect do
        self.quit
      end

      self.set_accels_for_action("app.quit", {"<primary>q"})
      self.set_accels_for_action("win.open", {"<Ctrl>o"})
      self.set_accels_for_action("win.save-as", {"<Ctrl><Shift>s"})

      self.add_action about_action
      self.add_action preferences_action
      self.add_action quit_action
    end

    @[GObject::Virtual]
    def activate
      win = self.active_window
      if win.nil?
        win = Text::Viewer::Window.new
        win.application = self
      end
      win.present
    end

    private def on_about_action
      Adw::AboutDialog.new(
        application_name: "text-viewer",
        application_icon: "com.example.TextViewer",
        version: VERSION,
        copyright: "© 2024 Evangelos Paterakis",
        developer_name: "Evangelos \"GeopJr\" Paterakis",
      ).present(self.active_window)
    end

    private def on_preferences_action
      puts "app.preferences action activated"
    end
  end

  app = App.new
  exit(app.run(nil))
end
