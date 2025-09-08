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

  handleFileSelect(event) {
    const files = event.target.files

    console.log("Files selected:", files)
  }
}