import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput"]

  upload() {
    console.log("Select a file to upload")
    this.fileInputTarget.click()
  }

  connect() {
    this.fileInputTarget.addEventListener('change', this.handleFileSelect.bind(this)) 
  }

  async handleFileSelect(event) {
    const files = event.target.files

    const file = files[0]

    try {
      const preSignedData = await this.getPresignedUrl(file)
      console.log("Received pre signed url: ", preSignedData.url)
    } catch(error) {
      console.log("Upload failed:", error)
    }

    this.getPresignedUrl(file)

    console.log("Files selected:", files)
  }

  async getPresignedUrl(file) {
    const response = await fetch("/files/presigned_url", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        filename: file.name,
        content_type: file.type,
        file_size: file.size
      })
    })

    if (!response.ok) {
      throw new Error("Failed to get presigned url")
    }

    return response.json()
  }
}