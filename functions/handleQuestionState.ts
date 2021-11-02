import { differenceInMilliseconds } from "date-fns";

import { Game } from "@takeoff/types";
import { db, firebase, sleep } from "@takeoff/lib";

export const handleQuestionState = async (
  game: Game,
  gameDocRef: firebase.firestore.DocumentReference
) => {
  let questionDuration = differenceInMilliseconds(
    game.currentQuestionDeadline.toDate(),
    firebase.firestore.Timestamp.now().toDate()
  );

  if (questionDuration <= 0) {
    questionDuration =
      game?.questions?.[game.currentQuestionIndex]?.duration * 1000;
  }
  console.log("[BEGIN] QUESTION STATE", {
    currentQuestionIndex: game.currentQuestionIndex,
    questionDuration,
  });

  await sleep(questionDuration);

  await db.runTransaction(async (transaction) => {
    const freshGameDoc = await transaction.get(gameDocRef);
    const freshGame = freshGameDoc.data();

    if (freshGame.state === Game.State.Question) {
      transaction.update(gameDocRef, {
        state: Game.State.AnswerReveal,
      });
    } else {
      console.warn(
        `handleQuestionState encountered unexpected game state "${freshGame.state}", skipping execution`
      );
    }
  });

  console.log("[END] QUESTION STATE", {
    currentQuestionIndex: game.currentQuestionIndex,
  });
};
