Puppet::Type.type(:dotnetwinservice).provide(:dotnetwinservice) do
	desc "Allows installation of Microsoft .Net based windows services using InstallUtil.exe"

  confine     :operatingsystem => :windows
  defaultfor  :operatingsystem => :windows

  INSTALLUTIL = "#{ENV['SYSTEMROOT']}\\Microsoft.NET\\Framework\\v4.0.30319\\InstallUtil.exe"

  commands :default_installutil => INSTALLUTIL

  def installutil(*args)
    # default to non-64 bit
   frameworkpath = @resource[:sixtyfourbit] ? "Framework64" : "Framework"

    if @resource[:dotnetversion]

      installutilpath = "#{ENV['SYSTEMROOT']}\\Microsoft.NET\\#{frameworkpath}\\v#{@resource[:dotnetversion]}\\InstallUtil.exe"
      if !File.exists?(installutilpath)
        raise Puppet::Error, "Cannot find installutil.exe at #{installutilpath}"
      end
      args.unshift installutilpath
      assemblypath = File.dirname(@resource[:path])
      Puppet.debug("Executing '#{args.inspect}'")
      Dir.chdir assemblypath do
        run_command(args)
      end
   else
      raise Puppet::Error, "No .Net version specified."
    end
  end

  def run_command(command)
     execute(command, :failonfail => true)
  end

  def create
      installutil("/unattended", @resource[:path])
  end

  def destroy
      installutil("/u", "/unattended", @resource[:path])
  end

  def exists?
      Win32::Service.exists?( @resource[:name] )
  end

end
