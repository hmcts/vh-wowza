#cloud-config
apt_sources:
  - source: "deb [arch=amd64 trusted=yes] https://packages.microsoft.com/ubuntu/14.04/prod trusty main"
package_upgrade: true
packages:
  - blobfuse
  - fuse
write_files:
  - owner: wowza:wowza
    path: /usr/local/WowzaStreamingEngine/conf/Server.xml
    content: |
      <?xml version="1.0" encoding="UTF-8"?>
      <Root version="2">
              <Server>
                      <Name>Wowza Streaming Engine</Name>
                      <Description>Wowza Streaming Engine is robust, customizable, and scalable server software that powers reliable streaming of high-quality video and audio to any device, anywhere.</Description>
                      <RESTInterface>
                              <Enable>true</Enable>
                              <IPAddress>*</IPAddress>
                              <Port>8087</Port>
                              <!-- none, basic, digest, remotehttp, digestfile -->
                              <AuthenticationMethod>digestfile</AuthenticationMethod>
                              <DiagnosticURLEnable>true</DiagnosticURLEnable>
                              <SSLConfig>
                                      <Enable>true</Enable>
                                      <KeyStorePath>/usr/local/WowzaStreamingEngine/conf/ssl.wowza.jks</KeyStorePath>
                                      <KeyStorePassword>${certPassword}</KeyStorePassword>
                                      <KeyStoreType>JKS</KeyStoreType>
                                      <SSLProtocol>TLS</SSLProtocol>
                                      <Algorithm>SunX509</Algorithm>
                                      <CipherSuites></CipherSuites>
                                      <Protocols></Protocols>
                              </SSLConfig>
                              <IPWhiteList>*</IPWhiteList>
                              <IPBlackList></IPBlackList>
                              <EnableXMLFile>false</EnableXMLFile>
                              <DocumentationServerEnable>false</DocumentationServerEnable>
                              <DocumentationServerPort>8089</DocumentationServerPort>
                              <!-- none, basic, digest, remotehttp, digestfile -->
                              <DocumentationServerAuthenticationMethod>digestfile</DocumentationServerAuthenticationMethod>
                              <Properties>
                              </Properties>
                      </RESTInterface>
                      <CommandInterface>
                              <HostPort>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                                      <IpAddress>*</IpAddress>
                                      <Port>8083</Port>
                              </HostPort>
                      </CommandInterface>
                      <AdminInterface>
                              <!-- Objects exposed through JMX interface: Server, VHost, VHostItem, Application, ApplicationInstance, MediaCaster, Module, Client, MediaStream, SharedObject, Acceptor, IdleWorker -->
                              <ObjectList>Server,VHost,VHostItem,Application,ApplicationInstance,MediaCaster,Module,IdleWorker</ObjectList>
                      </AdminInterface>
                      <Stats>
                              <Enable>true</Enable>
                      </Stats>
                      <!-- JMXUrl: service:jmx:rmi://localhost:8084/jndi/rmi://localhost:8085/jmxrmi -->
                      <JMXRemoteConfiguration>
                              <Enable>false</Enable>
                              <IpAddress>$${com.wowza.cloud.platform.PLATFORM_METADATA_EXTERNAL_IP}</IpAddress> <!--changed for default cloud install. <IpAddress>localhost</IpAddress>--> <!-- set to localhost or internal ip address if behind NAT -->
                              <RMIServerHostName>$${com.wowza.cloud.platform.PLATFORM_METADATA_EXTERNAL_IP}</RMIServerHostName> <!--changed for default cloud install. <RMIServerHostName>localhost</RMIServerHostName>--> <!-- set to external ip address or domain name if behind NAT -->
                              <RMIConnectionPort>8084</RMIConnectionPort>
                              <RMIRegistryPort>8085</RMIRegistryPort>
                              <Authenticate>true</Authenticate>
                              <PasswordFile>$${com.wowza.wms.ConfigHome}/conf/jmxremote.password</PasswordFile>
                              <AccessFile>$${com.wowza.wms.ConfigHome}/conf/jmxremote.access</AccessFile>
                              <SSLSecure>false</SSLSecure>
                      </JMXRemoteConfiguration>
                      <UserAgents>Shockwave Flash|CFNetwork|MacNetwork/1.0 (Macintosh)</UserAgents>
                      <Streams>
                              <DefaultStreamPrefix>mp4</DefaultStreamPrefix>
                      </Streams>
                      <ServerListeners>
                              <ServerListener>
                                      <BaseClass>com.wowza.wms.module.ServerListenerTranscoderPreload</BaseClass>
                              </ServerListener> <!--changed for default cloud install. -->
                              <ServerListener>
                                      <BaseClass>com.wowza.wms.plugin.cloud.platform.env.ServerListenerVariables</BaseClass>
                              </ServerListener> <!--changed for default cloud install. -->
                              <ServerListener>
                                      <BaseClass>com.wowza.wms.mediacache.impl.MediaCacheServerListener</BaseClass>
                              </ServerListener>
                              <!--
                              <ServerListener>
                                      <BaseClass>com.wowza.wms.plugin.loadbalancer.ServerListenerLoadBalancerListener</BaseClass>
                              </ServerListener>
                              -->
                              <!--
                              <ServerListener>
                                      <BaseClass>com.wowza.wms.plugin.loadbalancer.ServerListenerLoadBalancerSender</BaseClass>
                              </ServerListener>
                              -->
                      </ServerListeners>
                      <VHostListeners>
                              <!--
                              <VHostListener>
                                      <BaseClass></BaseClass>
                              </VHostListener>
                              -->
                      </VHostListeners>
                      <HandlerThreadPool>
                              <PoolSize>$${com.wowza.wms.TuningAuto}</PoolSize>
                      </HandlerThreadPool>
                      <TransportThreadPool>
                              <PoolSize>$${com.wowza.wms.TuningAuto}</PoolSize>
                      </TransportThreadPool>
                      <RTP>
                              <DatagramStartingPort>6970</DatagramStartingPort>
                              <DatagramPortSharing>false</DatagramPortSharing>
                      </RTP>
                      <Manager>
                              <!-- Properties defined are used by the Manager -->
                              <Properties>
                              </Properties>
                      </Manager>
                      <Transcoder>
                              <PluginPaths>
                                      <QuickSync></QuickSync>
                              </PluginPaths>
                      </Transcoder>
                      <!-- Properties defined here will be added to the IServer.getProperties() collection -->
                      <Properties>
                      </Properties>
              </Server>
      </Root>
  - owner: wowza:wowza
    path: /usr/local/WowzaStreamingEngine/conf/VHost.xml
    content: |
      <?xml version="1.0" encoding="UTF-8"?>
      <Root version="2">
              <VHost>
                      <Description></Description>
                      <HostPortList>
                              <HostPort>
                                      <Name>Default SSL Streaming</Name>
                                      <Type>Streaming</Type>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                                      <IpAddress>*</IpAddress>
                                      <Port>443</Port>
                                      <HTTPIdent2Response></HTTPIdent2Response>
                                      <SSLConfig>
                                              <Enable>true</Enable>
                                              <KeyStorePath>/usr/local/WowzaStreamingEngine/conf/ssl.wowza.jks</KeyStorePath>
                                              <KeyStorePassword>${certPassword}</KeyStorePassword>
                                              <KeyStoreType>JKS</KeyStoreType>
                                              <DomainToKeyStoreMapPath></DomainToKeyStoreMapPath>
                                              <SSLProtocol>TLS</SSLProtocol>
                                              <Algorithm>SunX509</Algorithm>
                                              <CipherSuites></CipherSuites>
                                              <Protocols></Protocols>
                                      </SSLConfig>
                                      <SocketConfiguration>
                                              <ReuseAddress>true</ReuseAddress>
                                              <ReceiveBufferSize>65000</ReceiveBufferSize>
                                              <ReadBufferSize>65000</ReadBufferSize>
                                              <SendBufferSize>65000</SendBufferSize>
                                              <KeepAlive>true</KeepAlive>
                                              <AcceptorBackLog>100</AcceptorBackLog>
                                      </SocketConfiguration>
                                      <HTTPStreamerAdapterIDs>cupertinostreaming,smoothstreaming,sanjosestreaming,dvrchunkstreaming,mpegdashstreaming</HTTPStreamerAdapterIDs>
                                      <HTTPProviders>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPCrossdomain</BaseClass>
                                                      <RequestFilters>*crossdomain.xml</RequestFilters>
                                                      <AuthenticationMethod>none</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPClientAccessPolicy</BaseClass>
                                                      <RequestFilters>*clientaccesspolicy.xml</RequestFilters>
                                                      <AuthenticationMethod>none</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPProviderMediaList</BaseClass>
                                                      <RequestFilters>*jwplayer.rss|*jwplayer.smil|*medialist.smil|*manifest-rtmp.f4m</RequestFilters>
                                                      <AuthenticationMethod>none</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPServerVersion</BaseClass>
                                                      <RequestFilters>*</RequestFilters>
                                                      <AuthenticationMethod>none</AuthenticationMethod>
                                              </HTTPProvider>
                                      </HTTPProviders>
                              </HostPort>
                              <HostPort>
                                      <Name>Default Admin</Name>
                                      <Type>Admin</Type>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                                      <IpAddress>*</IpAddress>
                                      <Port>8086</Port>
                                      <HTTPIdent2Response></HTTPIdent2Response>
                                      <SocketConfiguration>
                                              <ReuseAddress>true</ReuseAddress>
                                              <ReceiveBufferSize>16000</ReceiveBufferSize>
                                              <ReadBufferSize>16000</ReadBufferSize>
                                              <SendBufferSize>16000</SendBufferSize>
                                              <KeepAlive>true</KeepAlive>
                                              <AcceptorBackLog>100</AcceptorBackLog>
                                      </SocketConfiguration>
                                      <HTTPStreamerAdapterIDs></HTTPStreamerAdapterIDs>
                                      <HTTPProviders>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.streammanager.HTTPStreamManager</BaseClass>
                                                      <RequestFilters>streammanager*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPServerInfoXML</BaseClass>
                                                      <RequestFilters>serverinfo*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPConnectionInfo</BaseClass>
                                                      <RequestFilters>connectioninfo*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPConnectionCountsXML</BaseClass>
                                                      <RequestFilters>connectioncounts*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.transcoder.httpprovider.HTTPTranscoderThumbnail</BaseClass>
                                                      <RequestFilters>transcoderthumbnail*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPProviderMediaList</BaseClass>
                                                      <RequestFilters>medialist*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.livestreamrecord.http.HTTPLiveStreamRecord</BaseClass>
                                                      <RequestFilters>livestreamrecord*</RequestFilters>
                                                      <AuthenticationMethod>admin-digest</AuthenticationMethod>
                                              </HTTPProvider>
                                              <HTTPProvider>
                                                      <BaseClass>com.wowza.wms.http.HTTPServerVersion</BaseClass>
                                                      <RequestFilters>*</RequestFilters>
                                                      <AuthenticationMethod>none</AuthenticationMethod>
                                              </HTTPProvider>
                                      </HTTPProviders>
                              </HostPort>
                      </HostPortList>
                      <HTTPStreamerAdapters>
                              <HTTPStreamerAdapter>
                                      <ID>smoothstreaming</ID>
                                      <Name>smoothstreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>cupertinostreaming</ID>
                                      <Name>cupertinostreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>sanjosestreaming</ID>
                                      <Name>sanjosestreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>dvrchunkstreaming</ID>
                                      <Name>dvrchunkstreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>mpegdashstreaming</ID>
                                      <Name>mpegdashstreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>tsstreaming</ID>
                                      <Name>tsstreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                              <HTTPStreamerAdapter>
                                      <ID>webmstreaming</ID>
                                      <Name>webmstreaming</Name>
                                      <Properties>
                                      </Properties>
                              </HTTPStreamerAdapter>
                      </HTTPStreamerAdapters>
                      <!-- When set to zero, thread pool configuration is done in Server.xml -->
                      <HandlerThreadPool>
                              <PoolSize>0</PoolSize>
                      </HandlerThreadPool>
                      <TransportThreadPool>
                              <PoolSize>0</PoolSize>
                      </TransportThreadPool>
                      <IdleWorkers>
                              <WorkerCount>$${com.wowza.wms.TuningAuto}</WorkerCount>
                              <CheckFrequency>50</CheckFrequency>
                              <MinimumWaitTime>5</MinimumWaitTime>
                      </IdleWorkers>
                      <NetConnections>
                              <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              <IdleFrequency>250</IdleFrequency>
                              <SocketConfiguration>
                                      <ReuseAddress>true</ReuseAddress>
                                      <ReceiveBufferSize>65000</ReceiveBufferSize>
                                      <ReadBufferSize>65000</ReadBufferSize>
                                      <SendBufferSize>65000</SendBufferSize>
                                      <KeepAlive>true</KeepAlive>
                                      <!-- <TrafficClass>0</TrafficClass> -->
                                      <!-- <OobInline>false</OobInline> -->
                                      <!-- <SoLingerTime>-1</SoLingerTime> -->
                                      <!-- <TcpNoDelay>false</TcpNoDelay> -->
                                      <AcceptorBackLog>100</AcceptorBackLog>
                              </SocketConfiguration>
                      </NetConnections>
                      <MediaCasters>
                              <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              <SocketConfiguration>
                                      <ReuseAddress>true</ReuseAddress>
                                      <ReceiveBufferSize>65000</ReceiveBufferSize>
                                      <ReadBufferSize>65000</ReadBufferSize>
                                      <SendBufferSize>65000</SendBufferSize>
                                      <KeepAlive>true</KeepAlive>
                                      <!-- <TrafficClass>0</TrafficClass> -->
                                      <!-- <OobInline>false</OobInline> -->
                                      <!-- <SoLingerTime>-1</SoLingerTime> -->
                                      <!-- <TcpNoDelay>false</TcpNoDelay> -->
                                      <ConnectionTimeout>10000</ConnectionTimeout>
                              </SocketConfiguration>
                      </MediaCasters>
                      <LiveStreamTranscoders>
                              <MaximumConcurrentTranscodes>0</MaximumConcurrentTranscodes>
                      </LiveStreamTranscoders>
                      <HTTPTunnel>
                              <KeepAliveTimeout>2000</KeepAliveTimeout>
                      </HTTPTunnel>
                      <Client>
                              <ClientTimeout>90000</ClientTimeout>
                              <IdleFrequency>250</IdleFrequency>
                      </Client>
                      <!-- RTP/Authentication/Methods defined in Authentication.xml. Default setup includes; none, basic, digest -->
                      <RTP>
                              <IdleFrequency>75</IdleFrequency>
                              <DatagramConfiguration>
                                      <Incoming>
                                              <ReuseAddress>true</ReuseAddress>
                                              <ReceiveBufferSize>2048000</ReceiveBufferSize>
                                              <SendBufferSize>65000</SendBufferSize>
                                              <!-- <MulticastBindToAddress>true</MulticastBindToAddress> -->
                                              <!-- <MulticastInterfaceAddress>192.168.1.22</MulticastInterfaceAddress> -->
                                              <!-- <TrafficClass>0</TrafficClass> -->
                                              <MulticastTimeout>50</MulticastTimeout>
                                              <DatagramMaximumPacketSize>4096</DatagramMaximumPacketSize>
                                      </Incoming>
                                      <Outgoing>
                                              <ReuseAddress>true</ReuseAddress>
                                              <ReceiveBufferSize>65000</ReceiveBufferSize>
                                              <SendBufferSize>256000</SendBufferSize>
                                              <!-- <MulticastBindToAddress>true</MulticastBindToAddress> -->
                                              <!-- <MulticastInterfaceAddress>192.168.1.22</MulticastInterfaceAddress> -->
                                              <!-- <TrafficClass>0</TrafficClass> -->
                                              <MulticastTimeout>50</MulticastTimeout>
                                              <DatagramMaximumPacketSize>4096</DatagramMaximumPacketSize>
                                              <SendIGMPJoinMsgOnPublish>false</SendIGMPJoinMsgOnPublish>
                                      </Outgoing>
                              </DatagramConfiguration>
                              <UnicastIncoming>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              </UnicastIncoming>
                              <UnicastOutgoing>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              </UnicastOutgoing>
                              <MulticastIncoming>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              </MulticastIncoming>
                              <MulticastOutgoing>
                                      <ProcessorCount>$${com.wowza.wms.TuningAuto}</ProcessorCount>
                              </MulticastOutgoing>
                      </RTP>
                      <HTTPProvider>
                              <KeepAliveTimeout>2000</KeepAliveTimeout>
                              <KillConnectionTimeout>10000</KillConnectionTimeout>
                              <SlowConnectionBitrate>64000</SlowConnectionBitrate>
                              <IdleFrequency>250</IdleFrequency>
                      </HTTPProvider>
                      <WebSocket>
                              <MaximumMessageSize>512k</MaximumMessageSize>
                              <PacketFragmentationSize>0</PacketFragmentationSize>
                              <MaskOutgoingMessages>false</MaskOutgoingMessages>
                              <IdleFrequency>250</IdleFrequency>
                              <ValidationFrequency>20000</ValidationFrequency>
                              <MaximumPendingWriteBytes>0</MaximumPendingWriteBytes>
                              <PingTimeout>12000</PingTimeout>
                      </WebSocket>
                      <Application>
                              <ApplicationTimeout>60000</ApplicationTimeout>
                              <PingTimeout>12000</PingTimeout>
                              <UnidentifiedSessionTimeout>30000</UnidentifiedSessionTimeout>
                              <ValidationFrequency>20000</ValidationFrequency>
                              <MaximumPendingWriteBytes>0</MaximumPendingWriteBytes>
                              <MaximumSetBufferTime>60000</MaximumSetBufferTime>
                      </Application>
                      <StartStartupStreams>true</StartStartupStreams>
                      <Manager>
                              <TestPlayer>
                                      <IpAddress>$${com.wowza.cloud.platform.PLATFORM_METADATA_EXTERNAL_IP}</IpAddress>
                                      <!--changed for default cloud install. <IpAddress>$${com.wowza.wms.HostPort.IpAddress}</IpAddress>-->
                                      <Port>$${com.wowza.wms.HostPort.FirstStreamingPort}</Port>
                                      <SSLEnable>$${com.wowza.wms.HostPort.SSLEnable}</SSLEnable>
                              </TestPlayer>
                              <!-- Properties defined are used by the Manager -->
                              <Properties>
                              </Properties>
                      </Manager>
                      <!-- Properties defined here will be added to the IVHost.getProperties() collection -->
                      <Properties>
                      </Properties>
              </VHost>
      </Root>
  - owner: root:root
    path: /etc/rc.local
    content: |
      #!/bin/sh -e
      #
      # rc.local
      #
      # This script is executed at the end of each multiuser runlevel.
      # Make sure that the script will "exit 0" on success or any other
      # value on error.
      #
      # In order to enable or disable this script just change the execution
      # bits.
      #
      # By default this script does nothing.

      sudo bash /home/wowza/mount.sh /usr/local/WowzaStreamingEngine/content/azurecopy

      exit 0
  - owner: wowza:wowza
    path: /home/wowza/mount.sh
    content: |
      #!/bin/bash
      blobfuse $1 --tmp-path=/mnt/blobfusetmp -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --config-file=/home/wowza/connection.cfg -o allow_other -o nonempty
  - owner: wowza:wowza
    path: /home/wowza/connection.cfg
    content: |
      accountName ${storageAccountName}
      accountKey ${storageAccountKey}
      containerName recordings
  - owner: wowza:wowza
    path: /usr/local/WowzaStreamingEngine/conf/admin.password
    content: |
      # Admin password file (format [username][space][password])
      #username password group|group
      wowza ${restPassword} admin
  - owner: wowza:wowza
    path: /usr/local/WowzaStreamingEngine/conf/publish.password
    content: |
      # Publish password file (format [username][space][password])
      #username password
      wowza ${streamPassword}
runcmd:
  - 'sudo mkdir /mnt/blobfusetmp'
  - 'sudo mkdir /usr/local/WowzaStreamingEngine/content/azurecopy'
  - 'secretsname=$(find /var/lib/waagent/ -name "${certThumbprint}.prv" | cut -c -57)'
  - 'openssl pkcs12 -export -out $secretsname.pfx -inkey $secretsname.prv -in $secretsname.crt -passin pass: -passout pass:${certPassword}'
  - 'export PATH=$PATH:/usr/local/WowzaStreamingEngine/java/bin'
  - 'keytool -importkeystore -srckeystore $secretsname.pfx -srcstoretype pkcs12 -destkeystore /usr/local/WowzaStreamingEngine/conf/ssl.wowza.jks -deststoretype JKS -deststorepass ${certPassword} -srcstorepass ${certPassword}'
  - 'sudo bash /home/wowza/mount.sh /usr/local/WowzaStreamingEngine/content/azurecopy'
  - 'service WowzaStreamingEngine restart'

final_message: "The system is finally up, after $UPTIME seconds"
