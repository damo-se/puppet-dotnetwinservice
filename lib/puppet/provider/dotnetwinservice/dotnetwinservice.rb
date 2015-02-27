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
      Puppet.debug("Executing '#{args.inspect}'")
      execute(args, :failonfail => true)
    else
      raise Puppet::Error, "No .Net version specified."
    end
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
