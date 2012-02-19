{-# LANGUAGE ScopedTypeVariables #-}

-- This is how you would play a song with libsnd and portaudio with Haskell using Callbacks.
-- Because Haskell is GC, it is not recommended you use callbacks, this is simply for demo purposes
-- You should use blocking IO instead! Also never test code on with headphones or speakers on loud volume!

import qualified Sound.File.Sndfile as SF
import qualified Sound.File.Sndfile.Buffer.Vector as VSF
import qualified Data.Vector.Storable as V
import System.Environment (getArgs)

import Foreign.C.Types
import Foreign.Storable

import Sound.PortAudio.Base
import Sound.PortAudio

import Control.Concurrent
import Control.Applicative

processingFunction :: Vector CFloat -> IO ()
processingFunction vec = do
    

main :: IO ()
main = do
    [inFile] <- getArgs
    (info, Just (x :: VSF.Buffer Float)) <- SF.readFile inFile
    
    let vecData = VSF.fromBuffer x
    putStrLn $ "sample rate: " ++ (show $ SF.samplerate info)
    putStrLn $ "channels: "    ++ (show $ SF.channels info)
    putStrLn $ "frames: "      ++ (show $ SF.frames info)
    putStrLn $ "dataLen: "     ++ (show $ V.length vecData)

    result <- withPortAudio $ do
        withDefaultOutputInfo $ \(out, outInfo) -> do
            songDone <- newEmptyMVar

            let strmParams = Just $ StreamParameters out (fromIntegral $ SF.channels info) (defaultHighOutputLatency outInfo)
                smpRate = realToFrac $ SF.samplerate info
                frmPerBuf = Just $ fromIntegral framesPerBuffer
                framesPerBuffer = 2000


            withStream Nothing strmParams smpRate frmPerBuf [ClipOff] Nothing $ \strm -> do
                s2 <- startStream strm
                strm.
                s3 <- stopStream strm
                return $ Right ()

    case result of
        Left err -> print err
        Right _ -> return ()