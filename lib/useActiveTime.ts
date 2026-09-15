"use client";

import { useEffect, useRef } from "react";

const IDLE_THRESHOLD_MS = 60_000; // 60s with no interaction = not "active learning"

/**
 * Tracks active learning seconds for as long as this component is mounted:
 * ticks only while the tab is visible AND the user has interacted recently.
 * Returns a ref you can read at any time (e.g. right before completing a lesson).
 */
export function useActiveTime() {
  const activeSecondsRef = useRef(0);
  const lastInteractionRef = useRef(Date.now());

  useEffect(() => {
    const markActive = () => {
      lastInteractionRef.current = Date.now();
    };
    const events = ["mousemove", "keydown", "scroll", "touchstart", "click"];
    events.forEach((e) => window.addEventListener(e, markActive));

    const interval = setInterval(() => {
      const isVisible = document.visibilityState === "visible";
      const isRecentlyActive = Date.now() - lastInteractionRef.current < IDLE_THRESHOLD_MS;
      if (isVisible && isRecentlyActive) {
        activeSecondsRef.current += 1;
      }
    }, 1000);

    return () => {
      events.forEach((e) => window.removeEventListener(e, markActive));
      clearInterval(interval);
    };
  }, []);

  return activeSecondsRef;
}
