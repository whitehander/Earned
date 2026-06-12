import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { App } from "./App"
import { registerServiceWorker } from "./registerServiceWorker"
import "./styles.css"
import "./amountAnimation.css"
import "./notificationModal.css"

const root = document.getElementById("root")

if (root !== null) {
  createRoot(root).render(
    <StrictMode>
      <App />
    </StrictMode>,
  )
}

registerServiceWorker()
