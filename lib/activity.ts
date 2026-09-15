import { createClient } from "@/lib/supabase/client";

const QUEUE_KEY = "finops_pending_sync_v1";

type PendingCall = { fn: string; args: Record<string, unknown>; queuedAt: string };

function readQueue(): PendingCall[] {
  if (typeof window === "undefined") return [];
  try {
    return JSON.parse(localStorage.getItem(QUEUE_KEY) ?? "[]");
  } catch {
    return [];
  }
}

function writeQueue(queue: PendingCall[]) {
  if (typeof window === "undefined") return;
  localStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
}

function enqueue(call: PendingCall) {
  const queue = readQueue();
  queue.push(call);
  writeQueue(queue);
}

/** Call an RPC; if it fails (offline, etc.) queue it for later instead of losing the result. */
async function callOrQueue(fn: string, args: Record<string, unknown>) {
  const supabase = createClient();
  if (typeof navigator !== "undefined" && !navigator.onLine) {
    enqueue({ fn, args, queuedAt: new Date().toISOString() });
    return { queued: true } as const;
  }
  const { data, error } = await supabase.rpc(fn, args);
  if (error) {
    enqueue({ fn, args, queuedAt: new Date().toISOString() });
    return { queued: true, error } as const;
  }
  return { queued: false, data } as const;
}

/** Flush any queued calls once connectivity returns. Safe to call repeatedly. */
export async function flushPendingSync() {
  const queue = readQueue();
  if (queue.length === 0) return { flushed: 0 };
  const supabase = createClient();
  const remaining: PendingCall[] = [];
  let flushed = 0;

  for (const call of queue) {
    const { error } = await supabase.rpc(call.fn, call.args);
    if (error) remaining.push(call);
    else flushed += 1;
  }
  writeQueue(remaining);
  return { flushed, remaining: remaining.length };
}

export function pendingSyncCount() {
  return readQueue().length;
}

export async function trackLessonProgress(params: {
  lessonId: string;
  status: "in_progress" | "completed";
  progressPercentage: number;
  activeSeconds: number;
}) {
  return callOrQueue("track_lesson_progress", {
    p_lesson_id: params.lessonId,
    p_status: params.status,
    p_progress_percentage: params.progressPercentage,
    p_active_seconds: params.activeSeconds,
  });
}

export async function submitQuizAttempt(params: {
  quizId: string;
  answers: { question_id: string; given_answer: string }[];
  startedAt: string;
}) {
  return callOrQueue("submit_quiz_attempt", {
    p_quiz_id: params.quizId,
    p_answers: params.answers,
    p_started_at: params.startedAt,
  });
}

export async function submitChallengeAttempt(params: {
  challengeId: string;
  answers: Record<string, string>;
  decisions: Record<string, string>;
  startedAt: string;
}) {
  return callOrQueue("submit_challenge_attempt", {
    p_challenge_id: params.challengeId,
    p_answers: params.answers,
    p_decisions: params.decisions,
    p_started_at: params.startedAt,
  });
}

export async function submitCapstoneProject(params: {
  projectId: string;
  submissionData: Record<string, unknown>;
  checkedCriteria: string[];
  final: boolean;
}) {
  return callOrQueue("submit_capstone_project", {
    p_project_id: params.projectId,
    p_submission_data: params.submissionData,
    p_checked_criteria: params.checkedCriteria,
    p_final: params.final,
  });
}

export type InterviewResponse = { question_id: string; answer_text: string; self_rating: number | null };

export async function startInterviewSession(questionIds: string[]) {
  return callOrQueue("start_interview_session", { p_question_ids: questionIds });
}

export async function submitInterviewSession(params: {
  sessionId: string;
  responses: InterviewResponse[];
  final: boolean;
}) {
  return callOrQueue("submit_interview_session", {
    p_session_id: params.sessionId,
    p_responses: params.responses,
    p_final: params.final,
  });
}
