# Custom Storage Module
Mate by default ships with three storage modules; `Mate.Storage.Local`, `Mate.Storage.S3` and `Mate.Storage.BuildServer`. With these `mate` hopefully covers most scenarios, however if you have any desire for other storage solutions you can create your own storage module as well.

The storage module is responsible for uploading and downloading release archives to the storage of your choice. For examples you should take a look at the included storage modules, they are pretty small and the `Mate.Storage` behaviour only has two required functions; upload and download.

## The Storage Behaviour
A storage module should use the `Mate.Storage` behaviour, the documentation for that module explains all available functions.

    defmodule Mate.Storage.Custom do
      use Mate.Storage

      @impl true
      def download(session, file) do
        download_from_your_storage(file)
      end

      @impl true
      def upload(session, file) do
        upload_to_your_storage(file)
      end
    end
