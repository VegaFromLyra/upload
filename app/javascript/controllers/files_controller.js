import { Controller } from "@hotwired/stimulus"

const MAX_FILE_SIZE = 3 * 1024 * 1024 // 3MB
const ALLOWED_TYPES = [
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
  "application/pdf"
]

export default class extends Controller {
  static targets = ["fileInput", "status", "fileList"]

  upload() {
    this.fileInputTarget.click()
  }

  connect() {
    this.boundHandleFileSelect = this.handleFileSelect.bind(this)
    this.fileInputTarget.addEventListener("change", this.boundHandleFileSelect)
  }

  disconnect() {
    this.fileInputTarget.removeEventListener("change", this.boundHandleFileSelect)
  }

  async handleFileSelect(event) {
    const file = event.target.files[0]
    if (!file) return

    this.clearStatus()

    const error = this.validateFile(file)
    if (error) {
      this.showError(error)
      this.fileInputTarget.value = ""
      return
    }

    this.showStatus(`Uploading ${file.name}...`, "uploading")

    try {
      const presignedData = await this.getPresignedUrl(file)
      await this.uploadToS3(file, presignedData)
      this.showStatus(`${file.name} uploaded successfully!`, "success")
      this.addFileToList(file.name)
    } catch (error) {
      this.showError(`Upload failed: ${error.message}`)
    }

    this.fileInputTarget.value = ""
  }

  validateFile(file) {
    if (!ALLOWED_TYPES.includes(file.type)) {
      return "Invalid file type. Only images (JPEG, PNG, GIF, WebP) and PDFs are allowed."
    }
    if (file.size > MAX_FILE_SIZE) {
      return "File size exceeds 3MB limit."
    }
    return null
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
      const data = await response.json()
      throw new Error(data.error || "Failed to get presigned URL")
    }

    return response.json()
  }

  async uploadToS3(file, presignedData) {
    const formData = new FormData()

    Object.entries(presignedData.fields).forEach(([key, value]) => {
      formData.append(key, value)
    })
    formData.append("file", file)

    const response = await fetch(presignedData.url, {
      method: "POST",
      body: formData
    })

    if (!response.ok && response.status !== 204) {
      throw new Error("Failed to upload file to S3")
    }
  }

  showStatus(message, type) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `upload-status ${type}`
    }
  }

  showError(message) {
    this.showStatus(message, "error")
  }

  clearStatus() {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
      this.statusTarget.className = "upload-status"
    }
  }

  addFileToList(filename) {
    if (this.hasFileListTarget) {
      const li = document.createElement("li")
      li.textContent = filename
      this.fileListTarget.appendChild(li)
    }
  }
}
