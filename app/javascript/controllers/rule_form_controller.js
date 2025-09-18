import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "booleanValue", "percentageValue", "groupValue", "booleanInput", "percentageInput", "groupInput"]

  connect() {
    this.showValueField()
  }

  showValueField() {
    // Hide all fields and disable inputs
    this.hideAllFields()

    // Show selected field and enable input based on type
    const typeValue = this.typeTarget.value

    if (typeValue === 'boolean' && this.hasBooleanValueTarget) {
      this.booleanValueTarget.style.display = 'block'
      if (this.hasBooleanInputTarget) {
        this.booleanInputTarget.disabled = false
      }
    } else if (typeValue === 'percentage_of_actors' && this.hasPercentageValueTarget) {
      this.percentageValueTarget.style.display = 'block'
      if (this.hasPercentageInputTarget) {
        this.percentageInputTarget.disabled = false
      }
    } else if (typeValue === 'group' && this.hasGroupValueTarget) {
      this.groupValueTarget.style.display = 'block'
      if (this.hasGroupInputTarget) {
        this.groupInputTarget.disabled = false
      }
    }
  }

  hideAllFields() {
    // Boolean field
    if (this.hasBooleanValueTarget) {
      this.booleanValueTarget.style.display = 'none'
      if (this.hasBooleanInputTarget) {
        this.booleanInputTarget.disabled = true
      }
    }

    // Percentage field
    if (this.hasPercentageValueTarget) {
      this.percentageValueTarget.style.display = 'none'
      if (this.hasPercentageInputTarget) {
        this.percentageInputTarget.disabled = true
      }
    }

    // Group field
    if (this.hasGroupValueTarget) {
      this.groupValueTarget.style.display = 'none'
      if (this.hasGroupInputTarget) {
        this.groupInputTarget.disabled = true
      }
    }
  }
}