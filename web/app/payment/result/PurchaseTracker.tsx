"use client";

import { useEffect } from "react";
import { sendGAEvent } from "@next/third-parties/google";

/**
 * Fires a GA4 `purchase` conversion event once when a payment succeeds.
 * Rendered only on the success branch of the (server) payment result page.
 */
export default function PurchaseTracker({
  orderId,
}: {
  orderId?: string;
}) {
  useEffect(() => {
    sendGAEvent("event", "purchase", {
      transaction_id: orderId ?? "",
    });
  }, [orderId]);

  return null;
}
